import 'package:flutter/material.dart';
import '../../models/brand.dart';
import '../../models/product.dart';
import '../product_by_category_screen/product_by_category_screen.dart';

/// Keeps the existing brand navigation entry point but delegates display and
/// filtering to the same category browser used throughout the catalog.
class BrandProductsScreen extends StatelessWidget {
  const BrandProductsScreen(
      {super.key, required this.brand, required this.products});

  final Brand brand;
  // Retained for callers that already pass their catalog snapshot. The shared
  // browser reads the current provider snapshot so category and brand filters
  // remain consistent when the catalog refreshes.
  final List<Product> products;

  @override
  Widget build(BuildContext context) =>
      ProductByCategoryScreen(initialBrand: brand);
}
