import 'package:e_commerce_flutter/models/brand.dart';
import 'package:e_commerce_flutter/models/product.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/brand_products_screen.dart';
import 'package:e_commerce_flutter/utility/marketplace_design.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:e_commerce_flutter/widget/custom_network_image.dart';

class BrandsScreen extends StatelessWidget {
  const BrandsScreen({super.key, required this.brands, required this.products});

  final List<Brand> brands;
  final List<Product> products;

  List<Brand> get _sortedBrands {
    final uniqueByName = <String, Brand>{};
    for (final brand in brands) {
      final name = brand.name?.trim();
      if (name == null || name.isEmpty) continue;
      uniqueByName.putIfAbsent(_normalizeName(name), () => brand);
    }
    return uniqueByName.values.toList(growable: false);
  }

  static String _normalizeName(String name) =>
      name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  @override
  Widget build(BuildContext context) {
    final items = _sortedBrands;
    return Scaffold(
      backgroundColor: MarketPalette.pageCanvas(context),
      body: MarketBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
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
                        context.l10n.brands,
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
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          context.l10n.no_brands_available,
                          style: TextStyle(
                            color: MarketPalette.isDark(context)
                                ? MarketPalette.homeMuted
                                : MarketPalette.muted,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 11, 16, 18),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 5),
                        itemBuilder: (context, index) {
                          final brand = items[index];
                          return _BrandRow(
                            brand: brand,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BrandProductsScreen(
                                  brand: brand,
                                  products: products,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow({required this.brand, required this.onTap});

  final Brand brand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = brand.name ?? 'Brand';
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          height: 78,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xBFFFFFFF),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withValues(alpha: .85)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0B254B78),
                blurRadius: 9,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              _BrandMark(name: name, logoUrl: brand.logoUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MarketPalette.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9EB2C8),
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.name, this.logoUrl});

  final String name;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    if (logoUrl?.trim().isNotEmpty == true) {
      return SizedBox(
        width: 38,
        height: 38,
        child: CustomNetworkImage(
          imageUrl: logoUrl!.trim(),
          fit: BoxFit.contain,
        ),
      );
    }
    final key = name.toLowerCase().replaceAll(' ', '');
    const imageBrands = {
      'apple',
      'samsung',
      'google',
      'oneplus',
      'xiaomi',
      'sony',
      'oppo',
    };
    if (imageBrands.contains(key)) {
      return SizedBox(
        width: 38,
        height: 38,
        child: Center(
          child: SvgPicture.asset(
            'assets/images/brands/$key.svg',
            width: key == 'samsung' ? 38 : 29,
            height: key == 'samsung' ? 26 : 29,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    final mark = key == 'nothing' ? 'N' : name[0];
    return SizedBox(
      width: 38,
      height: 38,
      child: Center(
        child: Text(
          mark,
          style: TextStyle(
            color: key == 'nothing'
                ? const Color(0xFF172436)
                : const Color(0xFF49627E),
            fontSize: key == 'nothing' ? 25 : 22,
            height: 1,
            fontWeight: FontWeight.w800,
            letterSpacing: key == 'nothing' ? -2 : 0,
          ),
        ),
      ),
    );
  }
}
