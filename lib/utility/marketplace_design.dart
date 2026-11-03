import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Visual foundations for the blue, frosted-glass YoMart pages.
/// Kept separate from the app-wide theme so the approved reference screens
/// remain visually unchanged while other pages are updated incrementally.
abstract final class MarketPalette {
  static const Color midnight = Color(0xFF07162E);
  static const Color navy = Color(0xFF0D2B57);
  static const Color blue = Color(0xFF0877F9);
  static const Color blueDeep = Color(0xFF0649B2);
  static const Color sky = Color(0xFFBBDDFB);
  static const Color ice = Color(0xFFE8F3FF);
  static const Color lavender = Color(0xFFD9D8F7);
  static const Color ink = Color(0xFF102B4D);
  static const Color muted = Color(0xFF59718F);
  static const Color border = Color(0x80FFFFFF);
  static const Color field = Color(0xBFFFFFFF);
  static const Color error = Color(0xFFBA2F4A);
  static const Color success = Color(0xFF07866F);
  static const Color warning = Color(0xFFB66B08);
  static const Color warningLight = Color(0xFFFFF2D8);
  static const Color warningDark = Color(0xFF875000);
  static const Color homeBackground = Color(0xFF050C17);
  static const Color homeSurface = Color(0xFF111D31);
  static const Color homeSurfaceRaised = Color(0xFF1A2940);
  static const Color homeBorder = Color(0xFF30425E);
  static const Color homeMuted = Color(0xFF9AABC2);
  static const Color actionDark = Color(0xFF09172B);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color pageCanvas(BuildContext context) =>
      isDark(context) ? homeBackground : const Color(0xFFB5D8F8);

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB5D8F8), Color(0xFFEAF4FF), Color(0xFFC7DDF6)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF168BFF), Color(0xFF0754C7)],
  );
}

class MarketBackdrop extends StatelessWidget {
  const MarketBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = MarketPalette.isDark(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor:
            isDark ? const Color(0xFF091422) : const Color(0xFFF1F6FC),
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF08111F),
                    Color(0xFF050B15),
                    Color(0xFF0C1728),
                  ],
                )
              : MarketPalette.pageGradient,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (isDark) ...[
              const Positioned(
                top: -120,
                right: -110,
                child: _SoftGlow(color: Color(0x334A8BFF), size: 300),
              ),
              const Positioned(
                bottom: -150,
                left: -120,
                child: _SoftGlow(color: Color(0x222A63D0), size: 340),
              ),
            ] else ...[
              const Positioned(
                top: -110,
                right: -90,
                child: _SoftGlow(color: Color(0x8876B8FF), size: 300),
              ),
              const Positioned(
                bottom: -130,
                left: -110,
                child: _SoftGlow(color: Color(0x66B4A7F5), size: 340),
              ),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class _SoftGlow extends StatelessWidget {
  const _SoftGlow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 42, sigmaY: 42),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class MarketGlassCard extends StatelessWidget {
  const MarketGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius = 28,
    this.flat = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool flat;

  @override
  Widget build(BuildContext context) {
    if (flat) return Padding(padding: padding, child: child);

    final isDark = MarketPalette.isDark(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xE61A2940), Color(0xD9101C2F)],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xDFFFFFFF), Color(0xA8FFFFFF)],
                  ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: isDark ? MarketPalette.homeBorder : MarketPalette.border,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    isDark ? const Color(0x33000000) : const Color(0x2632568A),
                blurRadius: isDark ? 18 : 28,
                offset: Offset(0, isDark ? 8 : 14),
              ),
            ],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class MarketPrimaryButton extends StatelessWidget {
  const MarketPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
    this.loadingText = 'Please wait…',
    this.icon,
    this.dark = false,
    this.height,
    this.softShadow = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final String loadingText;
  final IconData? icon;
  final bool dark;
  final double? height;
  final bool softShadow;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final cornerRadius = dark ? 13.0 : 17.0;
    return SizedBox(
      height: height ?? (dark ? 46 : 54),
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled
              ? (dark
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF233148), Color(0xFF050A12)],
                    )
                  : MarketPalette.primaryGradient)
              : null,
          color: enabled
              ? null
              : (dark
                  ? MarketPalette.homeMuted.withValues(alpha: 0.35)
                  : MarketPalette.blue.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(cornerRadius),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: dark
                        ? Color(softShadow ? 0x26000000 : 0x55000000)
                        : const Color(0x3B0867D7),
                    blurRadius: softShadow ? 8 : 15,
                    offset: Offset(0, softShadow ? 3 : 7),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cornerRadius),
            ),
          ),
          child: loading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox.square(
                      dimension: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Text(
                      loadingText,
                      style: const TextStyle(fontSize: 14, height: 1),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        height: 1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// The app-wide action treatment for browsing or continuing through the catalog.
/// Its brand blue stays consistent in both themes and across compact hero CTAs.
class MarketBrowseButton extends StatelessWidget {
  const MarketBrowseButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.compact = false,
  });

  final String text;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final radius = compact ? 18.0 : 14.0;
    return SizedBox(
      height: compact ? 30 : 44,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0877F9), Color(0xFF0649B2)],
          ),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x29064FAF),
              blurRadius: 9,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(radius),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 10 : 13,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                  SizedBox(width: compact ? 5 : 7),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: compact ? 13 : 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
