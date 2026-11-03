import 'package:flutter/material.dart';
import 'app_color.dart';

class AppTheme {
  // Light Theme - Gentle and modern
  static ThemeData get lightAppTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFB5D8F8),

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColor.primary,
        primaryContainer: AppColor.primaryLight,
        secondary: AppColor.secondary,
        secondaryContainer: AppColor.secondaryLight,
        surface: AppColor.surface,
        error: AppColor.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColor.textPrimary,
        onError: Colors.white,
      ),

      // Text Theme - Fixed with explicit inherit values
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColor.textPrimary,
          inherit: true,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColor.textPrimary,
          inherit: true,
        ),
        displaySmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColor.textPrimary,
          inherit: true,
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColor.textPrimary,
          inherit: true,
        ),
        headlineSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColor.textPrimary,
          inherit: true,
        ),
        titleLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColor.textSecondary,
          inherit: true,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColor.textPrimary,
          inherit: true,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColor.textSecondary,
          inherit: true,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          inherit: true,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColor.textSecondary,
          inherit: true,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.normal,
          color: AppColor.textDisabled,
          inherit: true,
        ),
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColor.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColor.textPrimary,
          inherit: true,
        ),
        iconTheme: IconThemeData(
          color: AppColor.darkOrange,
          size: 24,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColor.darkOrange,
        unselectedItemColor: AppColor.textSecondary,
        selectedLabelStyle: TextStyle(fontSize: 12, inherit: true),
        unselectedLabelStyle: TextStyle(fontSize: 12, inherit: true),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColor.card,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.darkOrange,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            inherit: true,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColor.darkOrange,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            inherit: true,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColor.darkOrange,
          side: const BorderSide(color: AppColor.darkOrange, width: 1),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            inherit: true,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColor.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColor.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColor.darkOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColor.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColor.error, width: 2),
        ),
        labelStyle: const TextStyle(
          color: AppColor.textSecondary,
          fontSize: 14,
          inherit: true,
        ),
        hintStyle: const TextStyle(
          color: AppColor.textDisabled,
          fontSize: 14,
          inherit: true,
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFFF2F7FD),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFDDE8F3)),
        ),
        elevation: 4,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColor.divider,
        thickness: 1,
        space: 1,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColor.darkOrange,
        linearTrackColor: AppColor.primaryLight,
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColor.textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white, inherit: true),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColor.primaryLight,
        labelStyle: const TextStyle(color: AppColor.textPrimary, inherit: true),
        selectedColor: AppColor.primary,
        secondarySelectedColor: AppColor.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  // Dark Theme - Gentle dark mode
  static ThemeData get darkAppTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF050C17),

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColor.primary,
        primaryContainer: Color(0xFF37474F),
        secondary: AppColor.secondary,
        secondaryContainer: Color(0xFF37474F),
        surface: Color(0xFF121212),
        error: AppColor.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
      ),

      // Text Theme (dark) - Fixed with explicit inherit values
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          inherit: true,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          inherit: true,
        ),
        displaySmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          inherit: true,
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          inherit: true,
        ),
        headlineSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          inherit: true,
        ),
        titleLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFFB0BEC5),
          inherit: true,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.white,
          inherit: true,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Color(0xFFB0BEC5),
          inherit: true,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          inherit: true,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFFB0BEC5),
          inherit: true,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.normal,
          color: Color(0xFF757575),
          inherit: true,
        ),
      ),

      // App Bar Theme (dark)
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          inherit: true,
        ),
        iconTheme: IconThemeData(
          color: AppColor.primary,
          size: 24,
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF111D31),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF30425E)),
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        elevation: 8,
      ),

      // Card Theme (dark)
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Input Decoration Theme (dark)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF37474F), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF37474F), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColor.primary, width: 2),
        ),
        labelStyle: const TextStyle(
          color: Color(0xFFB0BEC5),
          fontSize: 14,
          inherit: true,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF757575),
          fontSize: 14,
          inherit: true,
        ),
      ),

      // Elevated Button Theme (dark)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.darkOrange,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            inherit: true,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Text Button Theme (dark)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColor.darkOrange,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            inherit: true,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // Divider Theme (dark)
      dividerTheme: const DividerThemeData(
        color: Color(0xFF37474F),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
