import 'package:e_commerce_flutter/utility/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import '../../../models/product.dart';

class FavoriteProvider extends ChangeNotifier {
  final box = GetStorage();
  List<Product> favoriteProduct = [];

  FavoriteProvider();

  void updateToFavoriteList(String productId) {
    List<dynamic> favoriteList = box.read(favoriteProductBox) ?? [];
    if (favoriteList.contains(productId)) {
      favoriteList.remove(productId);
    } else {
      favoriteList.add(productId);
    }
    box.write(favoriteProductBox, favoriteList);

    // Immediately update the local list
    _updateFavoriteProducts();
    notifyListeners();
  }

  bool checkIsItemFavorite(String productId) {
    List<dynamic> favoriteList = box.read(favoriteProductBox) ?? [];
    return favoriteList.contains(productId);
  }

  void loadFavoriteItems(List<Product> allProducts) {
    _updateFavoriteProducts(allProducts);
  }

  void _updateFavoriteProducts([List<Product>? allProducts]) {
    List<dynamic> favoriteListIds = box.read(favoriteProductBox) ?? [];
    if (allProducts != null) {
      favoriteProduct = allProducts.where((product) {
        return favoriteListIds.contains(product.sId);
      }).toList();
    }
  }

  void clearFavoriteList() {
    box.remove(favoriteProductBox);
    favoriteProduct.clear();
    notifyListeners();
  }
}
