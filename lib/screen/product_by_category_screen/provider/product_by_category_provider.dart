import 'package:flutter/cupertino.dart';
import '../../../models/brand.dart';
import '../../../models/category.dart';
import '../../../models/product.dart';
import '../../../models/sub_category.dart';

class ProductByCategoryProvider extends ChangeNotifier {
  List<Category> allCategories = [];
  Category? mySelectedCategory;
  SubCategory? mySelectedSubCategory;
  List<SubCategory> subCategories = [];
  List<Brand> brands = [];
  List<Brand> selectedBrands = [];
  List<Brand> _allBrands = [];
  List<Product> filteredProduct = [];
  List<Product> originalProducts = []; // Store original products for filtering

  filterInitialProductAndSubCategory(
      Category? selectedCategory,
      List<Product> allProducts,
      List<SubCategory> allSubCategories,
      List<Brand> allBrands,
      {Brand? initialBrand,
      List<Category>? categories}) {
    mySelectedSubCategory = SubCategory(name: 'All');
    mySelectedCategory = selectedCategory;
    allCategories = List<Category>.from(categories ?? []);
    _allBrands = List<Brand>.from(allBrands);
    selectedBrands.clear();
    subCategories = selectedCategory == null
        ? []
        : allSubCategories
            .where((element) => element.categoryId?.sId == selectedCategory.sId)
            .toList();
    subCategories.insert(0, SubCategory(name: 'All'));

    // Store original products
    originalProducts = selectedCategory == null
        ? List<Product>.from(allProducts)
        : allProducts
            .where((element) =>
                element.proCategoryId?.sId == selectedCategory.sId ||
                (selectedCategory.sId == null &&
                    element.proCategoryId?.name == selectedCategory.name))
            .toList();

    filteredProduct = List.from(originalProducts);

    _refreshBrands();
    if (initialBrand != null) {
      selectedBrands = brands
          .where((brand) =>
              brand.sId == initialBrand.sId ||
              _normalized(brand.name ?? '') ==
                  _normalized(initialBrand.name ?? ''))
          .toList();
      if (selectedBrands.isEmpty) selectedBrands = [initialBrand];
      filteredProduct = originalProducts
          .where((product) => _sameBrand(product.proBrandId, initialBrand))
          .toList();
    }

    notifyListeners();
  }

  void setCategories(List<Category> categories) {
    allCategories = List<Category>.from(categories);
  }

  void selectCategory(Category? category, List<Product> products,
      List<SubCategory> subCategories, List<Brand> brands,
      {Brand? initialBrand, List<Category>? categories}) {
    filterInitialProductAndSubCategory(
        category, products, subCategories, brands,
        initialBrand: initialBrand, categories: categories);
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
            .where((product) => selectedBrands
                .any((brand) => _sameBrand(product.proBrandId, brand)))
            .toList();

    notifyListeners();
  }

  static bool _sameBrand(ProRef? left, Brand right) =>
      (left?.sId != null && right.sId != null && left!.sId == right.sId) ||
      _normalized(left?.name ?? '') == _normalized(right.name ?? '');

  static String _normalized(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

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
