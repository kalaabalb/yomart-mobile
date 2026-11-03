import 'package:flutter/material.dart';

/// Shared breakpoints and sizing rules for phone, tablet, and desktop layouts.
abstract final class ResponsiveLayout {
  static const double tabletBreakpoint = 700;
  static const double desktopBreakpoint = 1080;
  static const double tabletContentMaxWidth = 920;
  static const double desktopContentMaxWidth = 1480;

  static double contentMaxWidth(double width) {
    if (width >= desktopBreakpoint) return desktopContentMaxWidth;
    if (width >= tabletBreakpoint) return tabletContentMaxWidth;
    return double.infinity;
  }

  static SliverGridDelegate productGridDelegate({
    double maxCardWidth = 280,
    double aspectRatio = .92,
  }) =>
      SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCardWidth,
        childAspectRatio: aspectRatio,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      );
}
