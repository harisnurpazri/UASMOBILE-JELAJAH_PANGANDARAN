import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';

class AppTheme {
  // Primary Colors - Orange Theme
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color lightOrange = Color(0xFFFF8C61);
  static const Color darkOrange = Color(0xFFE8551E);
  static const Color deepOrange = Color(0xFFD94414);

  // Backwards-compatible aliases
  static const Color primaryTeal = primaryOrange;
  static const Color lightTeal = lightOrange;
  static const Color darkTeal = darkOrange;

  // Background Colors - Warm tones
  static const Color backgroundColor = Color(0xFFFFF8F5);
  static const Color cardColor = Colors.white;
  static const Color surfaceColor = Color(0xFFFFF3ED);

  // Text Colors
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textLight = Color(0xFFAAAAAA);

  // Accent Colors - Orange palette
  static const Color accentOrange = Color(0xFFFF9F1C);
  static const Color accentDeepOrange = Color(0xFFFF5722);
  static const Color accentAmber = Color(0xFFFFB627);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentRed = Color(0xFFF44336);

  // Backwards-compatible aliases for older code
  static const Color accentBlue = primaryOrange;
  static const Color primaryBlue = primaryOrange;
  static const Color lightBlue = lightOrange;

  // Border Color
  static const Color borderColor = Color(0xFFFFE5D9);

  // Gradient - Orange theme
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF8F5), Color(0xFFFFE8DC), Color(0xFFFFD4BC)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B35), Color(0xFFFF8C61), Color(0xFFFFB627)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Color(0xFFFFFBF8)],
  );

  // Border Radius
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusXLarge = 32.0;

  // Shadows - Enhanced with orange tones
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: primaryOrange.withValues(alpha: 0.06),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 12,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: primaryOrange.withValues(alpha: 0.3),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: primaryOrange.withValues(alpha: 0.15),
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, 12),
    ),
  ];

  // ThemeData
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryOrange,
        primary: primaryOrange,
        secondary: lightOrange,
        surface: cardColor,
        tertiary: accentAmber,
      ),
      scaffoldBackgroundColor: backgroundColor,

      // Text Theme - use GoogleFonts on non-web platforms; on web fall back to
      // the system font to avoid runtime network font fetches that may fail.
      textTheme: kIsWeb
          ? ThemeData.light().textTheme.apply(fontFamily: 'Segoe UI').copyWith(
              displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              displayMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              displaySmall: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              headlineMedium: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
              bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: AppTheme.textPrimary),
              bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppTheme.textSecondary),
              bodySmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: AppTheme.textSecondary),
            )
          : GoogleFonts.poppinsTextTheme().copyWith(
              displayLarge: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
              displayMedium: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
              displaySmall: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
              headlineMedium: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
              titleLarge: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
              titleMedium: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
              bodyLarge: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: textPrimary,
              ),
              bodyMedium: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: textSecondary,
              ),
              bodySmall: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: textSecondary,
              ),
            ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusLarge)),
        ),
        color: cardColor,
      ),

      // Elevated Button Theme - Enhanced orange style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: primaryOrange.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Input Decoration Theme - Orange accents
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: accentRed),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: GoogleFonts.poppins(color: textLight, fontSize: 14),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: primaryOrange, size: 24),
      // Bottom Navigation Theme - modern floating style with orange
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        elevation: 12,
        selectedItemColor: primaryOrange,
        unselectedItemColor: textSecondary,
        showUnselectedLabels: true,
        selectedIconTheme: const IconThemeData(size: 26),
        unselectedIconTheme: const IconThemeData(size: 22),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // Dark Theme - Dark with orange accents
  static ThemeData get darkTheme {
    const darkBg = Color(0xFF1A1A1A);
    const darkCard = Color(0xFF2D2D2D);
    const darkTextPrimary = Color(0xFFF5F5F5);
    const darkTextSecondary = Color(0xFFB0B0B0);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: lightOrange,
        primary: lightOrange,
        secondary: primaryOrange,
        surface: darkCard,
        tertiary: accentAmber,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: darkBg,

      textTheme: kIsWeb
          ? ThemeData.dark().textTheme.apply(fontFamily: 'Segoe UI').copyWith(
              displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: darkTextPrimary),
              displayMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: darkTextPrimary),
              displaySmall: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkTextPrimary),
              headlineMedium: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: darkTextPrimary),
              titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: darkTextPrimary),
              titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: darkTextPrimary),
              bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: darkTextPrimary),
              bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: darkTextSecondary),
              bodySmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: darkTextSecondary),
            )
          : GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
              displayLarge: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: darkTextPrimary,
              ),
              displayMedium: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: darkTextPrimary,
              ),
              displaySmall: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: darkTextPrimary,
              ),
              headlineMedium: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: darkTextPrimary,
              ),
              titleLarge: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: darkTextPrimary,
              ),
              titleMedium: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: darkTextPrimary,
              ),
              bodyLarge: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: darkTextPrimary,
              ),
              bodyMedium: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: darkTextSecondary,
              ),
              bodySmall: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: darkTextSecondary,
              ),
            ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: darkTextPrimary,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
      ),

      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusLarge)),
        ),
        color: darkCard,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: lightOrange.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(
            color: darkTextSecondary.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(
            color: darkTextSecondary.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: lightOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: accentRed),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: GoogleFonts.poppins(color: darkTextSecondary, fontSize: 14),
      ),

      iconTheme: const IconThemeData(color: lightOrange, size: 24),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkCard,
        elevation: 12,
        selectedItemColor: lightOrange,
        unselectedItemColor: darkTextSecondary,
        showUnselectedLabels: true,
        selectedIconTheme: const IconThemeData(size: 26),
        unselectedIconTheme: const IconThemeData(size: 22),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
