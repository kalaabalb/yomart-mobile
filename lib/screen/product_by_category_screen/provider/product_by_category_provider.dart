import 'package:flutter/cupertino.dart';
import '../../../models/brand.dart';
import '../../../models/category.dart';
import '../../../models/product.dart';
import '../../../models/sub_category.dart';

class ProductByCategoryProvider extends ChangeNotifier {
  Category? mySelectedCategory;
  SubCategory? mySelectedSubCategory;
  List<SubCategory> subCategories = [];
  List<Brand> brands = [];
  List<Brand> selectedBrands = [];
  List<Brand> _allBrands = [];
  List<Product> filteredProduct = [];
  List<Product> originalProducts = []; // Store original products for filtering

  filterInitialProductAndSubCategory(
    Category selectedCategory,
    List<Product> allProducts,
    List<SubCategory> allSubCategories,
    List<Brand> allBrands,
  ) {
    mySelectedSubCategory = SubCategory(name: 'All');
    mySelectedCategory = selectedCategory;
    _allBrands = List<Brand>.from(allBrands);
    selectedBrands.clear();
    subCategories = allSubCategories
        .where((element) => element.categoryId?.sId == selectedCategory.sId)
        .toList();
    subCategories.insert(0, SubCategory(name: 'All'));

    // Store original products
    originalProducts = allProducts
        .where(
          (element) => element.proCategoryId?.name == selectedCategory.name,
        )
        .toList();

    filteredProduct = List.from(originalProducts);

    _refreshBrands();

    notifyListeners();
  }

  filterProductBySubCategory(
    SubCategory subCategory,
    List<Product> allProducts,
    List<Brand> allBrands,
  ) {
    mySelectedSubCategory = subCategory;
    if (subCategory.name?.toLowerCase() == 'all') {
      filteredProduct = List.from(originalProducts);
      _allBrands = List<Brand>.from(allBrands);
      brands = _brandsForProducts(_availableProductsForSubcategory());
      if (brands.isEmpty) {
        brands = _allBrands
            .where((element) =>
                element.subcategoryId?.name == mySelectedCategory?.name)
            .toList();
      }
    } else {
      filteredProduct = originalProducts
          .where(
            (element) => element.proSubCategoryId?.name == subCategory.name,
          )
          .toList();
      _allBrands = List<Brand>.from(allBrands);
      brands = _brandsForProducts(_availableProductsForSubcategory());
    }

    final visibleBrandIds = brands.map((brand) => brand.sId).toSet();
    selectedBrands.removeWhere((brand) => !visibleBrandIds.contains(brand.sId));

    // Apply brand filter if any brands are selected
    if (selectedBrands.isNotEmpty) {
      filterProductByBrand(originalProducts);
    }

    notifyListeners();
  }

  List<Product> _availableProductsForSubcategory() {
    final selectedName = mySelectedSubCategory?.name?.toLowerCase();
    if (selectedName == null || selectedName == 'all') {
      return originalProducts;
    }
    return originalProducts
        .where((product) =>
            product.proSubCategoryId?.name?.toLowerCase() == selectedName)
        .toList();
  }

  List<Brand> _brandsForProducts(List<Product> products) {
    final productBrandRefs = products
        .map((product) => product.proBrandId)
        .whereType<ProRef>()
        .toList();
    final brandIds =
        productBrandRefs.map((brand) => brand.sId).whereType<String>().toSet();
    final knownBrands = _allBrands
        .where((brand) => brand.sId != null && brandIds.contains(brand.sId))
        .toList();
    if (knownBrands.isNotEmpty) return knownBrands;

    final uniqueBrands = <String, Brand>{};
    for (final brand in productBrandRefs) {
      final key = brand.sId ?? brand.name?.toLowerCase();
      if (key != null) {
        uniqueBrands[key] = Brand(sId: brand.sId, name: brand.name);
      }
    }
    return uniqueBrands.values.toList();
  }

  void _refreshBrands() {
    brands = _brandsForProducts(originalProducts);
    if (brands.isEmpty) {
      brands = _allBrands
          .where(
              (brand) => brand.subcategoryId?.name == mySelectedCategory?.name)
          .toList();
    }
  }

  void filterProductByBrand(List<Product> allProducts) {
    final availableProducts = _availableProductsForSubcategory();
    filteredProduct = selectedBrands.isEmpty
        ? List<Product>.from(availableProducts)
        : availableProducts
            .where((product) => selectedBrands.any(
                  (brand) => product.proBrandId?.sId == brand.sId,
                ))
            .toList();

    notifyListeners();
  }

  void sortProducts({required bool ascending}) {
    filteredProduct.sort((a, b) {
      final priceA = a.offerPrice ?? a.price ?? 0;
      final priceB = b.offerPrice ?? b.price ?? 0;

      if (ascending) {
        return priceA.compareTo(priceB);
      } else {
        return priceB.compareTo(priceA);
      }
    });
    notifyListeners();
  }

  void updateUI() {
    notifyListeners();
  }
}
