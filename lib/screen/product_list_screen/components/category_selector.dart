import 'package:e_commerce_flutter/screen/product_by_category_screen/product_by_category_screen.dart';
import 'package:e_commerce_flutter/utility/marketplace_design.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:e_commerce_flutter/utility/catalog_localization.dart';
import 'package:flutter/material.dart';
import '../../../models/category.dart';
import '../../../models/brand.dart';
import '../../../widget/custom_network_image.dart';

class CategorySelector extends StatelessWidget {
  final List<Category> categories;
  final List<Brand> brands;
  final VoidCallback? onSamsungTap;
  final String? samsungImageUrl;

  const CategorySelector({
    super.key,
    required this.categories,
    this.brands = const [],
    this.onSamsungTap,
    this.samsungImageUrl,
  });

  IconData _iconFor(String name) {
    final value = name.toLowerCase();
    if (value.contains('phone')) return Icons.phone_iphone_rounded;
    if (value.contains('accessor')) return Icons.headphones_rounded;
    if (value.contains('tablet')) return Icons.tablet_mac_rounded;
    if (value.contains('watch')) return Icons.watch_rounded;
    if (value.contains('laptop')) return Icons.laptop_mac_rounded;
    if (value.contains('gaming')) return Icons.sports_esports_rounded;
    if (value.contains('audio')) return Icons.headphones_rounded;
    if (value.contains('home') || value.contains('office')) {
      return Icons.devices_other_rounded;
    }
    return Icons.devices_other_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final dark = MarketPalette.isDark(context);
    if (categories.isEmpty) {
      return SizedBox(
        height: 104,
        child: Center(
          child: Text(
            context.l10n.categories_unavailable,
            style: TextStyle(
              color: dark ? MarketPalette.homeMuted : MarketPalette.muted,
              fontSize: 10,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + (hasSamsungShortcut ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (hasSamsungShortcut && index == 1) {
            return SizedBox(
              width: 78,
              child: InkWell(
                borderRadius: BorderRadius.circular(32),
                onTap: onSamsungTap,
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: dark
                            ? const Color(0xFF243E5D)
                            : const Color(0xFFEAF2FA),
                        border: Border.all(
                          color: dark
                              ? MarketPalette.homeBorder
                              : const Color(0xFFD2E1EF),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x330080FF),
                            blurRadius: 16,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: samsungImageUrl?.isNotEmpty == true
                          ? CustomNetworkImage(
                              imageUrl: samsungImageUrl!, fit: BoxFit.cover)
                          : Icon(
                              Icons.phone_android_rounded,
                              color: dark
                                  ? const Color(0xFFB7D9FF)
                                  : const Color(0xFF42658A),
                              size: 34,
                            ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Samsung',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            dark ? const Color(0xFFE0E9F6) : MarketPalette.ink,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          final categoryIndex =
              hasSamsungShortcut && index > 1 ? index - 1 : index;
          final category = categories[categoryIndex];
          return SizedBox(
            width: 78,
            child: InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) =>
                      ProductByCategoryScreen(selectedCategory: category),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dark
                          ? const Color(0xFF243E5D)
                          : const Color(0xFFEAF2FA),
                      border: Border.all(
                        color: category.isSelected
                            ? const Color(0xFF2D91FF)
                            : (dark
                                ? MarketPalette.homeBorder
                                : const Color(0xFFD2E1EF)),
                        width: category.isSelected ? 1.5 : 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x330080FF),
                          blurRadius: 16,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: category.image?.isNotEmpty == true
                        ? CustomNetworkImage(
                            imageUrl: category.image!, fit: BoxFit.cover)
                        : Icon(
                            _iconFor(category.name ?? ''),
                            color: dark
                                ? const Color(0xFFB7D9FF)
                                : const Color(0xFF42658A),
                            size: 34,
                          ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    localizeCategoryName(context.l10n, category.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: dark ? const Color(0xFFE0E9F6) : MarketPalette.ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool get hasSamsungShortcut =>
      brands.any((brand) => brand.name?.toLowerCase() == 'samsung');
}
