import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:e_commerce_flutter/models/order.dart';
import 'package:e_commerce_flutter/screen/order_details_screen/order_details_screen.dart';
import 'package:e_commerce_flutter/utility/marketplace_design.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({
    super.key,
    required this.orderId,
    required this.amount,
  });

  final String? orderId;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A14),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -.3),
                    radius: 1,
                    colors: [Color(0xFF14243A), Color(0xFF050A14)],
                  ),
                ),
              ),
            ),
            ...List.generate(14, (index) {
              final colors = [
                const Color(0xFF00CBA0),
                const Color(0xFF1789FF),
                const Color(0xFFFF8B38),
                const Color(0xFFE94E7A),
              ];
              final left =
                  (index * 67.0 + 21) % (MediaQuery.sizeOf(context).width - 20);
              final top = 24.0 + ((index * 43.0) % 140);
              return Positioned(
                left: left,
                top: top,
                child: Transform.rotate(
                  angle: (index.isEven ? 1 : -1) * .65,
                  child: Container(
                    width: 4,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              );
            }),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 78,
                      height: 78,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10CDA0),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x4435E8C0),
                            blurRadius: 28,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Color(0xFF06251F), size: 48),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      context.l10n.order_placed_title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.l10n.order_submitted_message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Color(0xFFB8C5D8), height: 1.4),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      orderId == null || orderId!.isEmpty
                          ? context.l10n.total_birr(amount.toStringAsFixed(0))
                          : 'Order #${_shortId(orderId!)}',
                      style: const TextStyle(
                        color: Color(0xFFD4DFEF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _actionButton(
                      label: context.l10n.view_order_details,
                      primary: true,
                      onTap: () async {
                        final data = context.read<DataProvider>();
                        await data.getAllOrders();
                        Order? order;
                        for (final entry in data.orders) {
                          if (entry.sId == orderId) {
                            order = entry;
                            break;
                          }
                        }
                        if (!context.mounted) return;
                        if (order == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.l10n.order_details_loading),
                            ),
                          );
                          return;
                        }
                        // The confirmation screen is a one-time success page.
                        // Replace it so backing out of order details returns to
                        // the app beneath checkout instead of showing success
                        // again.
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderDetailsScreen(order: order!),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _actionButton(
                      label: context.l10n.continue_shopping_action,
                      primary: false,
                      onTap: () => Navigator.of(context)
                          .popUntil((route) => route.isFirst),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required bool primary,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: primary ? MarketPalette.primaryGradient : null,
          color: primary ? null : const Color(0xFF111F34),
          borderRadius: BorderRadius.circular(14),
          border: primary ? null : Border.all(color: const Color(0xFF263750)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _shortId(String id) =>
      id.length <= 8 ? id : id.substring(id.length - 8).toUpperCase();
}
