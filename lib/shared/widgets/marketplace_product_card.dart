import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:e_commerce_flutter/models/product.dart';
import 'package:e_commerce_flutter/screen/product_details_screen/product_detail_screen.dart';
import 'package:e_commerce_flutter/screen/product_favorite_screen/provider/favorite_provider.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:e_commerce_flutter/utility/marketplace_design.dart';
import 'package:e_commerce_flutter/widget/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MarketplaceProductCard extends StatelessWidget {
  const MarketplaceProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final dark = MarketPalette.isDark(context);
    return Consumer<FavoriteProvider>(
      builder: (context, favorites, child) => Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductDetailScreen(product)),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(9, 7, 9, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              gradient: dark
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0, 0.38, 1],
                      colors: [
                        Color(0xFFD9EAF8),
                        Color(0xFF718EAF),
                        Color(0xFF12233D),
                      ],
                    )
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFF8FBFF), Color(0xFFE0ECF8)],
                    ),
              border: Border.all(
                color: dark ? const Color(0x668EBAEF) : const Color(0xFFD6E4F2),
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      dark ? const Color(0x551C69C3) : const Color(0x15254B78),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomNetworkImage(
                          imageUrl: product.images?.firstOrNull?.url ?? '',
                          fit: BoxFit.contain,
                          placeholderColor: dark
                              ? const Color(0xFFBDD2E7)
                              : const Color(0xFFE5EDF6),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            final productId = product.sId;
                            if (productId == null) return;
                            favorites.updateToFavoriteList(productId);
                            favorites.loadFavoriteItems(
                              context.read<DataProvider>().allProducts,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              product.sId != null &&
                                      favorites
                                          .checkIsItemFavorite(product.sId!)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: dark
                                  ? const Color(0xFFE7F3FF)
                                  : const Color(0xFF496989),
                              size: 17,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  product.name ?? context.l10n.product,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: dark ? Colors.white : MarketPalette.ink,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Birr ${_formatPrice(product.offerPrice ?? product.price ?? 0)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        dark ? const Color(0xFFE7F3FF) : MarketPalette.blueDeep,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(num price) => price
      .round()
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}
