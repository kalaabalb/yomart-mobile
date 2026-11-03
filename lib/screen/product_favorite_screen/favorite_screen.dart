import 'package:e_commerce_flutter/screen/home_screen.dart';
import 'package:e_commerce_flutter/screen/product_favorite_screen/provider/favorite_provider.dart';
import 'package:e_commerce_flutter/shared/widgets/marketplace_empty_state.dart';
import 'package:e_commerce_flutter/widget/product_grid_view.dart';
import 'package:e_commerce_flutter/utility/marketplace_design.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:e_commerce_flutter/utility/snack_bar_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/data/data_provider.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  bool _isLoading = false;

  Future<void> _refreshData() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final favoriteProvider = context.read<FavoriteProvider>();
      final dataProvider = context.read<DataProvider>();

      await dataProvider.refreshAllData();
      favoriteProvider.loadFavoriteItems(dataProvider.allProducts);

      if (!mounted) return;

      SnackBarHelper.showSuccessSnackBar(context.l10n.favorites_refreshed);
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showErrorSnackBar(
        context.l10n.favorites_refresh_failed,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MarketBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 56,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: context.l10n.back,
                        visualDensity: VisualDensity.compact,
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20),
                        color: MarketPalette.isDark(context)
                            ? Colors.white
                            : MarketPalette.ink,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          context.l10n.my_favorites,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: MarketPalette.isDark(context)
                                ? Colors.white
                                : MarketPalette.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  child: Consumer2<FavoriteProvider, DataProvider>(
                    builder: (context, favoriteProvider, dataProvider, child) {
                      if (_isLoading) {
                        return _buildLoadingSkeleton();
                      }

                      favoriteProvider
                          .loadFavoriteItems(dataProvider.allProducts);

                      if (favoriteProvider.favoriteProduct.isEmpty) {
                        return _buildEmptyState();
                      }

                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: ProductGridView(
                          items: favoriteProvider.favoriteProduct,
                          marketStyle: true,
                        ),
                      );
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

  Widget _buildLoadingSkeleton() {
    return GridView.builder(
      itemCount: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 10 / 16,
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 16,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                Container(
                  height: 14,
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return MarketplaceEmptyState(
      icon: Icons.favorite_border_rounded,
      title: context.l10n.no_favorite_items,
      description: context.l10n.favorites_empty_description,
      actionLabel: context.l10n.browse_products,
      onAction: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      },
    );
  }
}
