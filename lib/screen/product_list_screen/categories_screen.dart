import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:e_commerce_flutter/models/category.dart';
import 'package:e_commerce_flutter/screen/product_by_category_screen/product_by_category_screen.dart';
import 'package:e_commerce_flutter/utility/marketplace_design.dart';
import 'package:e_commerce_flutter/utility/responsive_layout.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:e_commerce_flutter/utility/catalog_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketPalette.pageCanvas(context),
      body: MarketBackdrop(
        child: SafeArea(
          child: Consumer<DataProvider>(
            builder: (context, data, _) => Column(
              children: [
                SizedBox(
                  height: 58,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.chevron_left_rounded, size: 27),
                        color: MarketPalette.isDark(context)
                            ? Colors.white
                            : const Color(0xFF183450),
                        tooltip: context.l10n.back,
                      ),
                      Text(
                        context.l10n.categories,
                        style: TextStyle(
                          color: MarketPalette.isDark(context)
                              ? Colors.white
                              : const Color(0xFF142E49),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: data.categories.isEmpty && data.isCategoriesLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF5C94C9),
                            strokeWidth: 2,
                          ),
                        )
                      : data.categories.isEmpty
                          ? Center(
                              child: Text(
                                context.l10n.categories_unavailable,
                                style: TextStyle(
                                  color: MarketPalette.isDark(context)
                                      ? MarketPalette.homeMuted
                                      : const Color(0xFF687D93),
                                ),
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                              itemCount: data.categories.length,
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent:
                                    MediaQuery.sizeOf(context).width >=
                                            ResponsiveLayout.desktopBreakpoint
                                        ? 420
                                        : 360,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 1.12,
                              ),
                              itemBuilder: (context, index) => _CategoryTile(
                                  category: data.categories[index]),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final Category category;

  IconData _iconFor(String name) {
    final value = name.toLowerCase();
    if (value.contains('phone')) return Icons.phone_iphone_rounded;
    if (value.contains('accessor')) return Icons.headphones_rounded;
    if (value.contains('tablet')) return Icons.tablet_mac_rounded;
    if (value.contains('watch')) return Icons.watch_rounded;
    if (value.contains('laptop')) return Icons.laptop_mac_rounded;
    if (value.contains('gaming')) return Icons.sports_esports_rounded;
    if (value.contains('audio') || value.contains('head')) {
      return Icons.headphones_rounded;
    }
    if (value.contains('home') || value.contains('office')) {
      return Icons.devices_other_rounded;
    }
    return Icons.devices_other_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final name = category.name?.trim().isNotEmpty == true
        ? category.name!.trim()
        : context.l10n.category;

    return Material(
      color: const Color(0xFFEEF3F9),
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductByCategoryScreen(selectedCategory: category),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFE4ECF5),
                  shape: BoxShape.circle,
                ),
                child: category.image?.isNotEmpty == true
                    ? Image.network(
                        category.image!,
                        width: 46,
                        height: 46,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          _iconFor(name),
                          size: 34,
                          color: const Color(0xFF253D59),
                        ),
                      )
                    : Icon(
                        _iconFor(name),
                        size: 34,
                        color: const Color(0xFF253D59),
                      ),
              ),
              const Spacer(),
              Text(
                localizeCategoryName(context.l10n, name),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF182F49),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
