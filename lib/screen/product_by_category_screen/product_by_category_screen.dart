import '../../utility/extensions.dart';
import '../../models/brand.dart';
import '../../models/category.dart';
import '../../models/sub_category.dart';
import 'provider/product_by_category_provider.dart';
import '../../utility/marketplace_design.dart';
import '../../utility/catalog_localization.dart';
import '../../widget/custom_dropdown.dart';
import '../../widget/multi_select_drop_down.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widget/horizondal_list.dart';
import '../../widget/product_grid_view.dart';

class ProductByCategoryScreen extends StatefulWidget {
  final Category? selectedCategory;
  final Brand? initialBrand;

  const ProductByCategoryScreen(
      {super.key, this.selectedCategory, this.initialBrand});

  @override
  State<ProductByCategoryScreen> createState() =>
      _ProductByCategoryScreenState();
}

class _ProductByCategoryScreenState extends State<ProductByCategoryScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _initialized) return;
      _initialized = true;
      final proByCProvider = context.proByCProvider;
      final dataProvider = context.dataProvider;
      proByCProvider.filterInitialProductAndSubCategory(
        widget.selectedCategory,
        dataProvider.allProducts,
        dataProvider.subCategories,
        dataProvider.brands,
        initialBrand: widget.initialBrand,
        categories: dataProvider.categories,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final proByCProvider = context.proByCProvider;
    final dataProvider = context.dataProvider;
    final dark = MarketPalette.isDark(context);

    return Scaffold(
      backgroundColor: MarketPalette.pageCanvas(context),
      body: MarketBackdrop(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                floating: true,
                snap: true,
                title: Text(
                  localizeCategoryName(
                    context.l10n,
                    widget.selectedCategory?.name ??
                        widget.initialBrand?.name ??
                        context.l10n.products_heading,
                  ),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: dark ? Colors.white : MarketPalette.ink,
                  ),
                ),
                expandedHeight: 270,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 68, 16, 12),
                    child: MarketGlassCard(
                      padding: const EdgeInsets.fromLTRB(12, 5, 12, 7),
                      radius: 24,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 40,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _categoryChip(context, null,
                                    dataProvider.categories, proByCProvider),
                                for (final category in dataProvider.categories)
                                  _categoryChip(context, category,
                                      dataProvider.categories, proByCProvider),
                              ],
                            ),
                          ),
                          Consumer<ProductByCategoryProvider>(
                            builder: (context, proByCatProvider, child) {
                              if (proByCatProvider.subCategories.isEmpty) {
                                return const SizedBox(height: 42);
                              }
                              return SizedBox(
                                height: 48,
                                child: HorizontalList(
                                  items: proByCatProvider.subCategories,
                                  itemToString: (SubCategory? val) =>
                                      val?.name ?? '',
                                  selected:
                                      proByCatProvider.mySelectedSubCategory,
                                  onSelect: (val) {
                                    proByCatProvider.filterProductBySubCategory(
                                      val,
                                      dataProvider.allProducts,
                                      dataProvider.brands,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Expanded(
                                child: CustomDropdown<String>(
                                  hintText: context.l10n.sort_by_price,
                                  items: [
                                    context.l10n.low_to_high,
                                    context.l10n.high_to_low,
                                  ],
                                  onChanged: (val) {
                                    proByCProvider.sortProducts(
                                      ascending:
                                          val?.toLowerCase() == 'low to high',
                                    );
                                  },
                                  displayItem: (val) => val,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Consumer<ProductByCategoryProvider>(
                                  builder: (context, proByCatProvider, child) {
                                    return MultiSelectDropDown<Brand>(
                                      hintText: context.l10n.brands,
                                      items: proByCatProvider.brands,
                                      onSelectionChanged: (val) {
                                        proByCatProvider.selectedBrands = val;
                                        proByCatProvider.filterProductByBrand(
                                          dataProvider.allProducts,
                                        );
                                        proByCatProvider.updateUI();
                                      },
                                      displayItem: (val) => val.name ?? '',
                                      selectedItems:
                                          proByCatProvider.selectedBrands,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                sliver: SliverToBoxAdapter(
                  child: Consumer<ProductByCategoryProvider>(
                    builder: (context, proByCaProvider, child) {
                      final products = proByCaProvider.filteredProduct;
                      if (products.isEmpty) {
                        return MarketGlassCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 34,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                color: dark
                                    ? MarketPalette.homeMuted
                                    : MarketPalette.navy,
                                size: 34,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                context.l10n.no_products_match_filters,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:
                                      dark ? Colors.white : MarketPalette.ink,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                context.l10n.try_another_category,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: dark
                                        ? MarketPalette.homeMuted
                                        : MarketPalette.muted),
                              ),
                            ],
                          ),
                        );
                      }
                      return ProductGridView(
                          items: products, marketStyle: true);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(BuildContext context, Category? category,
      List<Category> categories, ProductByCategoryProvider provider) {
    final selected = category == null
        ? provider.mySelectedCategory == null
        : provider.mySelectedCategory?.sId == category.sId;
    final label = category == null
        ? context.l10n.all_filter
        : localizeCategoryName(context.l10n, category.name ?? '');
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => provider.selectCategory(
            category,
            context.dataProvider.allProducts,
            context.dataProvider.subCategories,
            context.dataProvider.brands,
            initialBrand: widget.initialBrand,
            categories: categories),
      ),
    );
  }
}
