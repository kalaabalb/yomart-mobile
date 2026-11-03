import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:e_commerce_flutter/models/product.dart';
import 'package:e_commerce_flutter/screen/product_details_screen/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cart/model/cart_model.dart';
import 'package:provider/provider.dart';
import '../provider/cart_provider.dart';
import '../../../utility/marketplace_design.dart';
import '../../../utility/extensions.dart';

class CartListSection extends StatelessWidget {
  final List<CartModel> cartProducts;

  const CartListSection({super.key, required this.cartProducts});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 12),
      itemCount: cartProducts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 7),
      itemBuilder: (context, index) => _CartItemCard(
        cartItem: cartProducts[index],
        product: _findProduct(context, cartProducts[index]),
        price: _getItemPrice(context, cartProducts[index]),
      ),
    );
  }

  double _getItemPrice(BuildContext context, CartModel cartItem) {
    if (cartItem.variants.isNotEmpty) return cartItem.variants.first.price;
    try {
      final product = context.read<DataProvider>().allProducts.firstWhere(
            (product) => product.sId == cartItem.productId,
          );
      return product.offerPrice ?? product.price ?? 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  Product? _findProduct(BuildContext context, CartModel cartItem) {
    for (final product in context.read<DataProvider>().allProducts) {
      if (product.sId == cartItem.productId) return product;
    }
    return null;
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.cartItem,
    required this.product,
    required this.price,
  });

  final CartModel cartItem;
  final Product? product;
  final double price;

  void _openDetails(BuildContext context) {
    final item = product;
    if (item == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.product_details_unavailable_now)),
        );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = cartItem.productImages?.isNotEmpty == true
        ? cartItem.productImages!.first
        : '';
    final variant = cartItem.variants.isNotEmpty
        ? [
            cartItem.variants.first.color?.trim(),
            cartItem.variants.first.size?.trim(),
          ].where((value) => value?.isNotEmpty == true).join(' · ')
        : '';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => _openDetails(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 96,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xDFFFFFFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: .9)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0E254B78),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F6FB),
                  borderRadius: BorderRadius.circular(15),
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl.isEmpty
                    ? const Icon(Icons.shopping_bag_outlined,
                        color: Color(0xFF9AAFC5), size: 28)
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.shopping_bag_outlined,
                          color: Color(0xFF9AAFC5),
                          size: 28,
                        ),
                      ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              cartItem.productName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: MarketPalette.ink,
                                fontSize: 13,
                                height: 1.15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        Tooltip(
                          message: context.l10n.view_product_details,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _openDetails(context),
                              borderRadius: BorderRadius.circular(16),
                              child: const SizedBox(
                                width: 36,
                                height: 36,
                                child: Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFF9EB2C8),
                                  size: 27,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (variant.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        variant,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF8297B0),
                          fontSize: 10,
                          height: 1.1,
                        ),
                      ),
                    ] else
                      const Spacer(),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Birr ${_formatAmount(price)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: MarketPalette.ink,
                              fontSize: 13,
                              height: 1,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        _QuantityButton(
                          icon: Icons.remove_rounded,
                          onTap: () => context
                              .read<CartProvider>()
                              .updateCart(cartItem, -1),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 27,
                          height: 27,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF4F7FB),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${cartItem.quantity}',
                            style: const TextStyle(
                              color: MarketPalette.ink,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _QuantityButton(
                          icon: Icons.add_rounded,
                          onTap: () => context
                              .read<CartProvider>()
                              .updateCart(cartItem, 1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatAmount(double amount) => amount == amount.roundToDouble()
      ? amount.toStringAsFixed(0)
      : amount.toStringAsFixed(2);
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF0F5FA),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 27,
          height: 27,
          child: Icon(icon, size: 15, color: const Color(0xFF657F9E)),
        ),
      ),
    );
  }
}
