import 'package:flutter/material.dart';

class AppColor {
  // Primary Colors - Gentle orange palette
  static const Color primaryLight = Color(0xFFFFF3E0); // Very light orange
  static const Color primary = Color(0xFFFFCC80); // Light orange
  static const Color primaryDark = Color(0xFFFFB74D); // Gentle orange
  static const Color darkOrange =
      Color.fromARGB(255, 141, 97, 52); // Subtle dark orange

  // Secondary Colors - Gentle blues
  static const Color secondaryLight = Color(0xFFE3F2FD);
  static const Color secondary = Color(0xFF90CAF9);
  static const Color secondaryDark = Color(0xFF42A5F5);

  // Accent Colors - Gentle purples
  static const Color accentLight = Color(0xFFF3E5F5);
  static const Color accent = Color(0xFFCE93D8);
  static const Color accentDark = Color(0xFFAB47BC);

  // Neutral Colors - Soft grays
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);

  // Gray colors - Add missing lightGrey
  static const Color lightGrey = Color(0xFFF5F5F5); // Added light grey
  static const Color mediumGrey = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF757575);

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);

  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFEEEEEE);

  // Status Colors - Gentle versions
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color success = Color(0xFF66BB6A);
  static const Color successDark = Color(0xFF388E3C);

  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color warning = Color(0xFFFFCA28);
  static const Color warningDark = Color(0xFFFFA000);

  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color error = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFFD32F2F);

  static const Color infoLight = Color(0xFFE1F5FE);
  static const Color info = Color(0xFF29B6F6);
  static const Color infoDark = Color(0xFF0288D1);

  // Gradient Colors - Gentle gradients
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [primaryLight, primary],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      );

  static LinearGradient get secondaryGradient => const LinearGradient(
        colors: [secondaryLight, secondary],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      );

  static LinearGradient get accentGradient => const LinearGradient(
        colors: [accentLight, accent],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      );

  static LinearGradient get successGradient => const LinearGradient(
        colors: [successLight, success],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      );

  // Card Colors - Very light backgrounds
  static const List<Color> cardColors = [
    Color(0xFFE3F2FD), // Light Blue
    Color(0xFFF3E5F5), // Light Purple
    Color(0xFFE8F5E9), // Light Green
    Color(0xFFFFF3E0), // Light Orange
    Color(0xFFFCE4EC), // Light Pink
    Color(0xFFF1F8E9), // Very Light Green
    Color(0xFFE0F7FA), // Light Cyan
    Color(0xFFEDE7F6), // Light Indigo
  ];

  // Get random gentle color
  static Color getRandomGentleColor() {
    return cardColors[DateTime.now().millisecond % cardColors.length];
  }

  // Get gradient for index
  static LinearGradient getGradientForIndex(int index) {
    final gradients = [
      primaryGradient,
      secondaryGradient,
      accentGradient,
      successGradient,
      const LinearGradient(
        colors: [Color(0xFFFCE4EC), Color(0xFFF48FB1)],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
    ];
    return gradients[index % gradients.length];
  }

  // Wave effect gradient
  static LinearGradient getWaveGradient(Color baseColor) {
    return LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        baseColor.withValues(alpha: 0.9),
        baseColor.withValues(alpha: 0.7),
        baseColor.withValues(alpha: 0.5),
        baseColor.withValues(alpha: 0.3),
        baseColor.withValues(alpha: 0.5),
        baseColor.withValues(alpha: 0.7),
      ],
      stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
    );
  }
}
