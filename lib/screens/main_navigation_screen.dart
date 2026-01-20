import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:animate_do/animate_do.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import 'home_screen_new.dart';
import 'wishlist_screen.dart';
import 'riwayat_booking_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load messages saat pertama kali login untuk update badge
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentProfile?.id;
      if (userId != null) {
        context.read<ChatProvider>().loadMessages(userId);
      }
    });
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Clear badge langsung saat tab Chat diklik
    if (index == 3) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final userId = authProvider.currentProfile?.id;

      // 1. Clear badge langsung (optimistic update)
      chatProvider.clearUserUnreadBadge();

      // 2. Update database di background
      if (userId != null) {
        chatProvider.markUserMessagesAsReadInDb(userId);
      }
    }
  }

  final List<Widget> _screens = [
    const HomeScreenNew(),
    const WishlistScreen(),
    const RiwayatBookingScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  List<NavigationItem> _getNavItems(int unreadCount) {
    debugPrint(
      '🟢 GET NAV ITEMS - unreadCount: $unreadCount, showBadge: ${unreadCount > 0}',
    );
    return [
      NavigationItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Beranda',
      ),
      NavigationItem(
        icon: Icons.favorite_outline,
        activeIcon: Icons.favorite,
        label: 'Favorit',
        showBadge: false,
      ),
      NavigationItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
        label: 'Riwayat',
      ),
      NavigationItem(
        icon: Icons.chat_bubble_outline,
        activeIcon: Icons.chat_bubble,
        label: 'Chat',
        showBadge: unreadCount > 0,
        badgeCount: unreadCount,
      ),
      NavigationItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profil',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          final unreadCount = chatProvider.getUnreadCount();
          debugPrint('🔵 CONSUMER REBUILD - Unread: $unreadCount');
          return _buildModernBottomNav(unreadCount);
        },
      ),
    );
  }

  Widget _buildModernBottomNav(int unreadCount) {
    final navItems = _getNavItems(unreadCount);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              navItems.length,
              (index) => _buildNavItem(index, navItems),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, List<NavigationItem> navItems) {
    final item = navItems[index];
    final isActive = _currentIndex == index;
    final color = isActive
        ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
        : Theme.of(context).bottomNavigationBarTheme.unselectedItemColor;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabChanged(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with badge (sama seperti admin)
              ZoomIn(
                duration: const Duration(milliseconds: 200),
                child: item.showBadge
                    ? badges.Badge(
                        badgeContent: Text(
                          '${item.badgeCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                        badgeStyle: const badges.BadgeStyle(
                          badgeColor: AppTheme.accentRed,
                        ),
                        child: Icon(
                          isActive ? item.activeIcon : item.icon,
                          color: color,
                          size: isActive ? 28 : 24,
                        ),
                      )
                    : Icon(
                        isActive ? item.activeIcon : item.icon,
                        color: color,
                        size: isActive ? 28 : 24,
                      ),
              ),
              const SizedBox(height: 4),
              // Label
              Text(
                item.label,
                style: TextStyle(
                  fontSize: isActive ? 12 : 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: color,
                ),
              ),
              // Active indicator
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 3,
                width: isActive ? 20 : 0,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool showBadge;
  final int badgeCount;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.showBadge = false,
    this.badgeCount = 0,
  });
}
