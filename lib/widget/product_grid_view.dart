import 'package:e_commerce_flutter/models/product.dart';
import 'package:e_commerce_flutter/screen/product_details_screen/product_detail_screen.dart';
import 'package:e_commerce_flutter/screen/product_favorite_screen/provider/favorite_provider.dart';
import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:e_commerce_flutter/utility/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/widgets/product_widgets.dart';

class ProductGridView extends StatelessWidget {
  final List<Product> items;
  final bool marketStyle;

  const ProductGridView({
    super.key,
    required this.items,
    this.marketStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No products found',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      );
    }

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: ResponsiveLayout.productGridDelegate(
        maxCardWidth: 280,
        // Extra vertical room keeps product cards within the short viewport
        // grid rows on compact Android phones such as the Galaxy A32.
        aspectRatio: .74,
      ),
      itemBuilder: (context, index) {
        final product = items[index];
        return Consumer<FavoriteProvider>(
          builder: (context, favoriteProvider, child) {
            final isFavorite =
                favoriteProvider.checkIsItemFavorite(product.sId!);

            // Constrain card width for desktop layouts
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: ProductGridItem(
                  product: product,
                  marketStyle: marketStyle,
                  onTap: () {
                    // Navigate directly to product details
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(product),
                      ),
                    );
                  },
                  onFavoriteTap: () {
                    favoriteProvider.updateToFavoriteList(product.sId!);
                    favoriteProvider
                        .loadFavoriteItems(context.dataProvider.allProducts);
                  },
                  isFavorite: isFavorite,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
