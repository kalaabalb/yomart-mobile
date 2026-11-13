import 'package:e_commerce_flutter/screen/product_favorite_screen/provider/favorite_provider.dart';
import 'package:e_commerce_flutter/widget/custom_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../utility/app_color.dart';
import '../../utility/marketplace_design.dart';
import '../../utility/preview_catalog.dart';
import 'package:provider/provider.dart';

class ProductGridItem extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final bool isFavorite;
  final bool marketStyle;

  const ProductGridItem({
    super.key,
    required this.product,
    required this.onTap,
    required this.onFavoriteTap,
    required this.isFavorite,
    this.marketStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = marketStyle && MarketPalette.isDark(context);
    final cardSurface =
        isDark ? MarketPalette.homeSurface : const Color(0xDFFFFFFF);
    final primaryText = isDark ? Colors.white : MarketPalette.ink;
    final hasDiscount = product.offerPrice != null &&
        product.offerPrice != product.price &&
        product.offerPrice! < product.price!;
    final discountPercent = hasDiscount
        ? ((product.price! - product.offerPrice!) / product.price! * 100)
            .round()
        : 0;

    return Card(
      color: marketStyle ? cardSurface : null,
      elevation: marketStyle ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(marketStyle ? 22 : 12),
        side: marketStyle
            ? BorderSide(
                color: isDark ? MarketPalette.homeBorder : MarketPalette.border,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(marketStyle ? 22 : 12),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final imageHeight = (constraints.maxHeight * .46)
                  .clamp(82.0, marketStyle ? 154.0 : 126.0);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: imageHeight,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(marketStyle ? 16 : 8),
                          color: marketStyle
                              ? (isDark
                                  ? MarketPalette.homeSurfaceRaised
                                  : const Color(0x99EAF4FF))
                              : Colors.grey[100],
                        ),
                        child: CustomNetworkImage(
                          imageUrl: product.images?.isNotEmpty == true
                              ? product.images!.first.url ?? ''
                              : '',
                          fit: marketStyle ? BoxFit.contain : BoxFit.cover,
                        ),
                      ),
                      if (hasDiscount)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: marketStyle
                                  ? MarketPalette.blueDeep
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$discountPercent% OFF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: onFavoriteTap,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? MarketPalette.homeBackground
                                      .withValues(alpha: .94)
                                  : Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey[600],
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.name ?? 'Unknown Product',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: marketStyle ? primaryText : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (canDisplayCatalogPrice(
                      previewMode: isPreviewCatalog,
                      price: product.offerPrice ?? product.price)) ...[
                    const SizedBox(height: 4),
                    Consumer<FavoriteProvider>(
                      builder: (context, favoriteProvider, child) {
                        return Row(
                          children: [
                            Flexible(
                              child: Text(
                                "Birr ${product.offerPrice ?? product.price}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: marketStyle
                                      ? (isDark
                                          ? const Color(0xFF67B4FF)
                                          : MarketPalette.blueDeep)
                                      : AppColor.darkOrange,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasDiscount) ...[
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Birr ${product.price}',
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                  if (!isPreviewCatalog) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.quantity != 0 ? 'In Stock' : 'Out of Stock',
                      style: TextStyle(
                        color: product.quantity != 0
                            ? (marketStyle
                                ? MarketPalette.success
                                : Colors.green)
                            : (marketStyle ? MarketPalette.error : Colors.red),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
