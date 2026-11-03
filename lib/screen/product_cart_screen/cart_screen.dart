import 'package:e_commerce_flutter/screen/product_cart_screen/components/cart_list_section.dart';
import 'package:e_commerce_flutter/screen/product_cart_screen/checkout_flow_screen.dart';
import 'package:e_commerce_flutter/screen/product_cart_screen/components/empty_cart.dart';
import 'package:e_commerce_flutter/screen/product_cart_screen/provider/cart_provider.dart';
import 'package:e_commerce_flutter/utility/animation/animated_switcher_wrapper.dart';
import 'package:e_commerce_flutter/utility/marketplace_design.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CartProvider>().getCartItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketPalette.pageCanvas(context),
      body: MarketBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 13, 20, 11),
                child: Consumer<CartProvider>(
                  builder: (context, cart, _) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.your_cart,
                              style: TextStyle(
                                color: MarketPalette.isDark(context)
                                    ? Colors.white
                                    : MarketPalette.ink,
                                fontSize: 21,
                                height: 1.15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -.3,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              context.l10n.cart_item_count(
                                  cart.myCartItems.length.toString()),
                              style: TextStyle(
                                color: MarketPalette.isDark(context)
                                    ? MarketPalette.homeMuted
                                    : MarketPalette.muted,
                                fontSize: 13,
                                height: 1.15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 34,
                        height: 34,
                        child: IconButton(
                          tooltip: context.l10n.refresh_cart,
                          onPressed: cart.getCartItems,
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.refresh_rounded,
                            size: 19,
                            color: Color(0xFF9FB2C8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: MarketPalette.blue,
                  onRefresh: () async =>
                      context.read<CartProvider>().getCartItems(),
                  child: Consumer<CartProvider>(
                    builder: (context, cart, _) {
                      if (cart.myCartItems.isEmpty) return const EmptyCart();
                      return CartListSection(cartProducts: cart.myCartItems);
                    },
                  ),
                ),
              ),
              Consumer<CartProvider>(
                builder: (context, cart, _) {
                  if (cart.myCartItems.isEmpty) return const SizedBox.shrink();
                  final total = cart.getCartSubTotal();
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(22, 7, 22, 13),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              context.l10n.subtotal,
                              style: TextStyle(
                                color: MarketPalette.isDark(context)
                                    ? MarketPalette.homeMuted
                                    : MarketPalette.muted,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            AnimatedSwitcherWrapper(
                              child: Text(
                                'Birr ${_formatAmount(total)}',
                                key: ValueKey<double>(total),
                                style: TextStyle(
                                  color: MarketPalette.isDark(context)
                                      ? Colors.white
                                      : MarketPalette.ink,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        _CheckoutButton(
                          label: context.l10n.checkout,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CheckoutFlowScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    return amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
  }
}

class _CheckoutButton extends StatelessWidget {
  const _CheckoutButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: MarketPalette.primaryGradient,
        boxShadow: const [
          BoxShadow(
            color: Color(0x33065EC9),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
