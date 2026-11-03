import 'package:flutter/cupertino.dart';
import '../../../models/product.dart';

class ProductListProvider extends ChangeNotifier {
  List<Product> _filteredProducts = [];
  String _searchQuery = '';

  List<Product> get filteredProducts => _filteredProducts;
  String get searchQuery => _searchQuery;

  ProductListProvider() {
    // Initialize with empty filtered products
    _filteredProducts = [];
  }

  void updateProducts(List<Product> allProducts) {
    if (_searchQuery.isEmpty) {
      _filteredProducts = allProducts;
    } else {
      _performSearch(_searchQuery, allProducts);
    }
    notifyListeners();
  }

  void searchProducts(String query, List<Product> allProducts) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredProducts = allProducts;
    } else {
      _performSearch(query, allProducts);
    }
    notifyListeners();
  }

  void _performSearch(String query, List<Product> allProducts) {
    final lowercaseQuery = query.toLowerCase();
    _filteredProducts = allProducts.where((product) {
      return (product.name ?? '').toLowerCase().contains(lowercaseQuery) ||
          (product.description ?? '').toLowerCase().contains(lowercaseQuery) ||
          (product.proCategoryId?.name ?? '')
              .toLowerCase()
              .contains(lowercaseQuery) ||
          (product.proBrandId?.name ?? '')
              .toLowerCase()
              .contains(lowercaseQuery);
    }).toList();
  }

  void clearSearch(List<Product> allProducts) {
    _searchQuery = '';
    _filteredProducts = allProducts;
    notifyListeners();
  }

  void refreshData(List<Product> allProducts) {
    if (_searchQuery.isEmpty) {
      _filteredProducts = allProducts;
    } else {
      _performSearch(_searchQuery, allProducts);
    }
    notifyListeners();
  }
}
