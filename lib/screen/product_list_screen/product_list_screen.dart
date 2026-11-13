import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/components/category_selector.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/components/custom_app_bar.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/collections_screen.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/components/poster_section.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/provider/product_list_provider.dart';
import 'package:e_commerce_flutter/shared/widgets/marketplace_product_card.dart';
import 'package:e_commerce_flutter/utility/marketplace_design.dart';
import 'package:e_commerce_flutter/utility/catalog_navigation.dart';
import 'package:e_commerce_flutter/utility/responsive_layout.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:e_commerce_flutter/utility/snack_bar_helper.dart';
import 'package:e_commerce_flutter/models/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key, this.onSearch});

  final VoidCallback? onSearch;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _productsSectionKey = GlobalKey();
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _browseProductSection() {
    browseCatalogFromPoster(
      productList: context.read<ProductListProvider>(),
      products: context.read<DataProvider>().allProducts,
      revealProducts: () {
        final sectionContext = _productsSectionKey.currentContext;
        if (sectionContext == null) return;
        Scrollable.ensureVisible(
          sectionContext,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          alignment: .05,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketPalette.pageCanvas(context),
      extendBodyBehindAppBar: false,
      appBar: CustomAppBar(
        onSearchTap: widget.onSearch,
        onCollections: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CollectionsScreen()),
        ),
      ),
      body: MarketBackdrop(
        child: SafeArea(
          top: false,
          child: Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              if (dataProvider.isLoading && dataProvider.allProducts.isEmpty) {
                return _buildLoadingSkeleton();
              }

              return RefreshIndicator(
                color: const Color(0xFF4AABFF),
                backgroundColor: MarketPalette.isDark(context)
                    ? MarketPalette.homeSurfaceRaised
                    : Colors.white,
                onRefresh: () async {
                  try {
                    final productListProvider =
                        context.read<ProductListProvider>();
                    await dataProvider.refreshAllData();
                    productListProvider.refreshData(dataProvider.allProducts);
                    if (!context.mounted) return;
                    SnackBarHelper.showSuccessSnackBar(
                      context.l10n.catalog_refreshed,
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    SnackBarHelper.showErrorSnackBar(
                      context.l10n.catalog_load_error,
                    );
                  }
                },
                child: _buildContent(context, dataProvider),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DataProvider dataProvider) {
    final products = context.watch<ProductListProvider>();
    final samsungBrand = dataProvider.brands
        .where((brand) => brand.name?.trim().toLowerCase() == 'samsung')
        .firstOrNull;
    final samsungProducts = dataProvider.allProducts
        .where((product) =>
            product.proBrandId?.name?.trim().toLowerCase() == 'samsung')
        .toList();
    final visibleProducts = List<Product>.of(products.searchQuery.isEmpty
        ? dataProvider.allProducts
        : products.filteredProducts);
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          dataProvider.isPostersLoading && dataProvider.posters.isEmpty
              ? _buildPostersLoadingSkeleton()
              : PosterSection(onBrowse: _browseProductSection),
          const SizedBox(height: 15),
          dataProvider.isCategoriesLoading && dataProvider.categories.isEmpty
              ? _buildCategoriesLoadingSkeleton()
              : CategorySelector(
                  categories: dataProvider.categories,
                  brands: dataProvider.brands,
                  samsungImageUrl: samsungBrand?.logoUrl,
                  onSamsungTap: samsungBrand == null
                      ? null
                      : () => openBrandProducts(
                            context,
                            brand: samsungBrand,
                            products: samsungProducts,
                          ),
                ),
          const SizedBox(height: 9),
          Text(
            key: _productsSectionKey,
            context.l10n.products_heading,
            style: TextStyle(
              color: MarketPalette.isDark(context)
                  ? Colors.white
                  : MarketPalette.ink,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (dataProvider.isProductsLoading && visibleProducts.isEmpty)
            _buildProductsLoadingSkeleton()
          else if (visibleProducts.isEmpty)
            _buildNoProductsState(dataProvider, products.searchQuery)
          else
            _buildProductGrid(context, visibleProducts),
        ],
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, List<Product> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 10, bottom: 8),
      gridDelegate: ResponsiveLayout.productGridDelegate(),
      itemCount: products.length,
      itemBuilder: (context, index) =>
          MarketplaceProductCard(product: products[index]),
    );
  }

  Widget _buildNoProductsState(DataProvider dataProvider, String query) {
    final searching = query.trim().isNotEmpty;
    final dark = MarketPalette.isDark(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: dark
            ? MarketPalette.homeSurface.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: .68),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: dark ? MarketPalette.homeBorder : const Color(0xFFDCE8F4)),
      ),
      child: Column(
        children: [
          Icon(
              searching
                  ? Icons.search_off_rounded
                  : Icons.wifi_tethering_error_rounded,
              size: 24,
              color: const Color(0xFF69B4FF)),
          const SizedBox(height: 5),
          Text(
              searching
                  ? context.l10n.no_search_matches
                  : context.l10n.catalog_unavailable,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: dark ? Colors.white : MarketPalette.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(
              searching
                  ? context.l10n.try_another_category
                  : context.l10n.check_connection_retry,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: dark ? MarketPalette.homeMuted : MarketPalette.muted,
                  fontSize: 10)),
          if (!searching) ...[
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: () => dataProvider.refreshAllData(),
              icon: const Icon(Icons.refresh_rounded, size: 14),
              label: Text(context.l10n.try_again,
                  style: const TextStyle(fontSize: 11)),
              style: TextButton.styleFrom(
                  foregroundColor:
                      dark ? const Color(0xFF91C9FF) : MarketPalette.blueDeep,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 10)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          _homeShimmer(double.infinity, 130),
          const SizedBox(height: 18),
          _buildCategoriesLoadingSkeleton(),
          const SizedBox(height: 20),
          _buildProductsLoadingSkeleton(),
        ],
      ),
    );
  }

  Widget _homeShimmer(double width, double height) => Shimmer.fromColors(
        baseColor: MarketPalette.isDark(context)
            ? MarketPalette.homeSurface
            : const Color(0xFFDDE8F4),
        highlightColor: MarketPalette.isDark(context)
            ? MarketPalette.homeSurfaceRaised
            : const Color(0xFFF5F9FE),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: MarketPalette.isDark(context)
                ? MarketPalette.homeSurface
                : const Color(0xFFDDE8F4),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );

  Widget _buildPostersLoadingSkeleton() => _homeShimmer(double.infinity, 165);

  Widget _buildCategoriesLoadingSkeleton() => SizedBox(
        height: 88,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) => Column(
            children: [
              _homeShimmer(52, 52),
              const SizedBox(height: 7),
              _homeShimmer(44, 10),
            ],
          ),
        ),
      );

  Widget _buildProductsLoadingSkeleton() => SizedBox(
        height: 155,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          separatorBuilder: (context, index) => const SizedBox(width: 11),
          itemBuilder: (context, index) => _homeShimmer(143, 155),
        ),
      );
}
