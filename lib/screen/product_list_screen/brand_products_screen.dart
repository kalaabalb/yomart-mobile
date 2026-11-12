import 'package:e_commerce_flutter/models/brand.dart';
import 'package:e_commerce_flutter/models/product.dart';
import 'package:e_commerce_flutter/screen/product_details_screen/product_detail_screen.dart';
import 'package:e_commerce_flutter/utility/marketplace_design.dart';
import 'package:e_commerce_flutter/utility/preview_catalog.dart';
import 'package:e_commerce_flutter/utility/responsive_layout.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:e_commerce_flutter/widget/custom_network_image.dart';
import 'package:flutter/material.dart';

class BrandProductsScreen extends StatelessWidget {
  const BrandProductsScreen({
    super.key,
    required this.brand,
    required this.products,
  });

  final Brand brand;
  final List<Product> products;

  List<Product> get _brandProducts {
    final brandId = brand.sId;
    final normalizedName = _normalize(brand.name ?? '');
    return products.where((product) {
      final productBrand = product.proBrandId;
      // The database keeps one brand record per subcategory, so products
      // from the same maker can reference different Brand document IDs.
      final sameName = _normalize(productBrand?.name ?? '') == normalizedName;
      return sameName || (brandId != null && productBrand?.sId == brandId);
    }).toList(growable: false);
  }

  static String _normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  @override
  Widget build(BuildContext context) {
    final items = _brandProducts;
    return Scaffold(
      backgroundColor: MarketPalette.pageCanvas(context),
      body: MarketBackdrop(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                child: Row(
                  children: [
                    Material(
                      color: const Color(0xFFE4EDF7),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.pop(context),
                        child: const SizedBox(
                          width: 36,
                          height: 36,
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Color(0xFF536E8D),
                            size: 17,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        brand.name ?? context.l10n.brand,
                        style: TextStyle(
                          color: MarketPalette.isDark(context)
                              ? Colors.white
                              : MarketPalette.ink,
                          fontSize: 18,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                child: Text(
                  context.l10n.trending,
                  style: TextStyle(
                    color: MarketPalette.isDark(context)
                        ? Colors.white
                        : MarketPalette.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            context.l10n.no_brand_products(
                                brand.name ?? context.l10n.brand),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: MarketPalette.isDark(context)
                                  ? MarketPalette.homeMuted
                                  : MarketPalette.muted,
                            ),
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 2, 16, 20),
                        itemCount: items.length,
                        gridDelegate: ResponsiveLayout.productGridDelegate(),
                        itemBuilder: (context, index) =>
                            _BrandProductCard(product: items[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandProductCard extends StatelessWidget {
  const _BrandProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.images?.firstOrNull?.url ?? '';
    final price = product.offerPrice ?? product.price ?? 0;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product)),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xEFFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: .9)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10254B78),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      placeholderColor: const Color(0xFFEAF1F8),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? context.l10n.product,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: MarketPalette.ink,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      isPreviewCatalog ? 'Price to be confirmed' : 'Birr ${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: MarketPalette.ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
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
}
