import 'package:e_commerce_flutter/screen/product_details_screen/provider/rating_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/data/data_provider.dart';
import '../screen/login_screen/provider/user_provider.dart';
import '../screen/profile_screen/provider/profile_provider.dart';
import '../screen/product_list_screen/provider/product_list_provider.dart';
import '../screen/product_by_category_screen/provider/product_by_category_provider.dart';
import '../screen/product_details_screen/provider/product_detail_provider.dart';
import '../screen/product_cart_screen/provider/cart_provider.dart';
import '../screen/product_favorite_screen/provider/favorite_provider.dart';
import '../l10n/app_localizations.dart';

extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension DataProviderExtension on BuildContext {
  DataProvider get dataProvider => read<DataProvider>();
}

extension UserProviderExtension on BuildContext {
  UserProvider get userProvider => read<UserProvider>();
}

extension ProfileProviderExtension on BuildContext {
  ProfileProvider get profileProvider => read<ProfileProvider>();
}

extension ProductListProviderExtension on BuildContext {
  ProductListProvider get productListProvider => read<ProductListProvider>();
}

extension ProductByCategoryProviderExtension on BuildContext {
  ProductByCategoryProvider get proByCProvider =>
      read<ProductByCategoryProvider>();
}

extension RatingProviderExtension on BuildContext {
  RatingProvider get ratingProvider =>
      Provider.of<RatingProvider>(this, listen: false);
}

extension ProductDetailProviderExtension on BuildContext {
  ProductDetailProvider get proDetailProvider => read<ProductDetailProvider>();
}

extension CartProviderExtension on BuildContext {
  CartProvider get cartProvider => read<CartProvider>();
}

extension FavoriteProviderExtension on BuildContext {
  FavoriteProvider get favoriteProvider => read<FavoriteProvider>();
}

extension SafeDataProviderExtension on BuildContext {
  DataProvider get safeDataProvider {
    try {
      return read<DataProvider>();
    } catch (e) {
      // Return a mock or handle the error appropriately
      throw FlutterError(
        'DataProvider not found in context. Make sure it\'s provided above in the widget tree.',
      );
    }
  }
}
