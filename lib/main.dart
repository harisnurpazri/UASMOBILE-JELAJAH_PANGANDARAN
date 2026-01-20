import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'config/constants.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/wisata_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/pesanan_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/review_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/admin_main_navigation.dart';
import 'screens/chat_screen.dart';
import 'screens/admin_chat_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);

  // Load environment variables from .env (if present)
  // Loading a local `.env` file on web will attempt to fetch `assets/.env`.
  // If the file isn't present (common for CI or when using --dart-define),
  // `dotenv.load` throws a FileNotFoundError which crashes the app. Wrap
  // load in try/catch so the app still runs and falls back to
  // `String.fromEnvironment` values.
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Not fatal — most users will supply the key via --dart-define
    // or via CI secrets; log for debugging and continue.
    debugPrint('dotenv: .env not found or failed to load: $e');
  }

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WisataProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => PesananProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, _) {
          if (themeProvider.isLoading) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(body: Center(child: CircularProgressIndicator())),
            );
          }

          return MaterialApp(
            title: 'Pangandaran Explore',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: FutureBuilder<Widget>(
              future: _determineInitialScreen(authProvider.isAuthenticated),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return snapshot.data ?? const OnboardingScreen();
              },
            ),
            routes: {
              '/onboarding': (context) => const OnboardingScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const MainNavigationScreen(),
              '/admin': (context) => const AdminMainNavigation(),
              '/chat': (context) => const ChatScreen(),
              '/admin-chat': (context) => const AdminChatScreen(),
            },
          );
        },
      ),
    );
  }

  Future<Widget> _determineInitialScreen(bool isAuthenticated) async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

    if (!onboardingComplete) {
      return const OnboardingScreen();
    }

    if (!isAuthenticated) {
      return const LoginScreen();
    }

    return const _AuthenticatedRouter();
  }
}

// Router widget that checks admin status
class _AuthenticatedRouter extends StatefulWidget {
  const _AuthenticatedRouter();

  @override
  State<_AuthenticatedRouter> createState() => _AuthenticatedRouterState();
}

class _AuthenticatedRouterState extends State<_AuthenticatedRouter> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Check if widget is still mounted before accessing context
        if (!mounted) {
          return const SizedBox.shrink();
        }

        // Wait for auth provider to load profile
        if (authProvider.currentProfile == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Route based on admin status
        if (authProvider.isAdmin) {
          return const AdminMainNavigation();
        } else {
          return const MainNavigationScreen();
        }
      },
    );
  }
}
