import 'package:e_commerce_flutter/utility/marketplace_design.dart';
import 'package:flutter/material.dart';

/// Shared empty state styling for the cart and saved favorites.
class MarketplaceEmptyState extends StatelessWidget {
  const MarketplaceEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final dark = MarketPalette.isDark(context);
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: dark
                              ? MarketPalette.homeSurfaceRaised
                              : const Color(0xBFEAF3FC),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: dark
                                ? MarketPalette.homeBorder
                                : const Color(0xFFD8E7F5),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          icon,
                          size: 39,
                          color: dark
                              ? const Color(0xFF76B9FF)
                              : MarketPalette.blueDeep,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: dark ? Colors.white : MarketPalette.ink,
                          fontSize: 18,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: dark
                              ? MarketPalette.homeMuted
                              : MarketPalette.muted,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 232),
                        child: MarketBrowseButton(
                          text: actionLabel,
                          onPressed: onAction,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
