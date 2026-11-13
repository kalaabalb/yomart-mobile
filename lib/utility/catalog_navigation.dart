import 'package:flutter/material.dart';
import '../models/brand.dart';
import '../models/product.dart';
import '../screen/product_list_screen/brand_products_screen.dart';
import '../screen/product_list_screen/provider/product_list_provider.dart';

/// Promotional copy is not a search query. A poster with no configured
/// destination browses the complete catalog and reveals its product section.
void browseCatalogFromPoster({
  required ProductListProvider productList,
  required List<Product> products,
  required VoidCallback revealProducts,
}) {
  productList.clearSearch(products);
  revealProducts();
}

void openBrandProducts(
  BuildContext context, {
  required Brand brand,
  required List<Product> products,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BrandProductsScreen(brand: brand, products: products),
    ),
  );
}
