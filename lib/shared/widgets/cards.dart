import 'package:e_commerce_flutter/utility/app_color.dart';
import 'package:flutter/material.dart';
import '../../utility/marketplace_design.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool useGradient;
  final double elevation;
  final bool marketStyle;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.backgroundColor,
    this.useGradient = false,
    this.elevation = 1,
    this.marketStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    if (marketStyle) {
      return MarketGlassCard(
        padding: EdgeInsets.zero,
        radius: 18,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(padding: padding, child: child),
        ),
      );
    }

    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: backgroundColor ?? Theme.of(context).cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final bool isTotal;
  final Color? valueColor;
  final bool marketStyle;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    this.isTotal = false,
    this.valueColor,
    this.marketStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: isTotal
            ? Border.all(
                color: AppColor.primary.withValues(alpha: 0.2),
                width: 1,
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: valueColor ??
                  (marketStyle
                      ? (isTotal ? MarketPalette.blueDeep : MarketPalette.ink)
                      : isTotal
                          ? AppColor.darkOrange
                          : Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
        ],
      ),
    );
  }
}
