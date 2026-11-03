import 'package:e_commerce_flutter/screen/home_screen.dart';
import 'package:e_commerce_flutter/shared/widgets/marketplace_empty_state.dart';
import 'package:flutter/material.dart';
import '../../../utility/extensions.dart';

class EmptyCart extends StatelessWidget {
  const EmptyCart({super.key});

  @override
  Widget build(BuildContext context) {
    return MarketplaceEmptyState(
      icon: Icons.shopping_bag_outlined,
      title: context.l10n.cart_empty_message,
      description: context.l10n.empty_cart_description,
      actionLabel: context.l10n.browse_products,
      onAction: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      },
    );
  }
}
