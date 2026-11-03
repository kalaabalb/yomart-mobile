import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../l10n/app_localizations.dart';
import '../../../models/category.dart';
import '../../models/api_response.dart';
import '../../models/brand.dart';
import '../../models/collection.dart';
import '../../models/order.dart';
import '../../models/poster.dart';
import '../../models/product.dart';
import '../../models/sub_category.dart';
import '../../models/store_settings.dart';
import '../../models/story.dart';
import '../../models/retailer_contact.dart';
import '../../services/http_services.dart';
import '../../utility/constants.dart';
import '../../utility/snack_bar_helper.dart';

class DataProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final box = GetStorage();

  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];
  List<Category> get categories => _filteredCategories;

  List<SubCategory> _allSubCategories = [];
  List<SubCategory> _filteredSubCategories = [];
  List<SubCategory> get subCategories => _filteredSubCategories;

  List<Brand> _allBrands = [];
  List<Brand> _filteredBrands = [];
  List<Brand> get brands => _filteredBrands;

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _allProducts;

  List<Poster> _allPosters = [];
  List<Poster> _filteredPosters = [];
  List<Poster> get posters => _filteredPosters;

  List<StoreCollection> _collections = [];
  List<StoreCollection> get collections => _collections;
  bool _isCollectionsLoading = false;
  bool get isCollectionsLoading => _isCollectionsLoading;
  bool _collectionsFailedToLoad = false;
  bool get collectionsFailedToLoad => _collectionsFailedToLoad;
  StoreSettings _storeSettings = StoreSettings.defaults;
  StoreSettings get storeSettings => _storeSettings;
  bool _hasLoadedStoreSettings = false;
  bool get hasLoadedStoreSettings => _hasLoadedStoreSettings;
  List<Story> _stories = [];
  List<Story> get stories => _stories;
  bool _isStoriesLoading = false;
  bool get isStoriesLoading => _isStoriesLoading;
  String? _storiesError;
  String? get storiesError => _storiesError;
  List<RetailerContact> _retailerContacts = [];
  List<RetailerContact> get retailerContacts => _retailerContacts;
  bool _isRetailerContactsLoading = false;
  bool get isRetailerContactsLoading => _isRetailerContactsLoading;
  String? _retailerContactsError;
  String? get retailerContactsError => _retailerContactsError;

  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];
  List<Order> get orders => _filteredOrders;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  String _currentLanguage = 'en';
  String get currentLanguage => _currentLanguage;

  // Loading states
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isCategoriesLoading = true;
  bool get isCategoriesLoading => _isCategoriesLoading;

  bool _isProductsLoading = true;
  bool get isProductsLoading => _isProductsLoading;

  bool _isPostersLoading = true;
  bool get isPostersLoading => _isPostersLoading;

  DataProvider() {
    _loadPreferences();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Request the actual resources directly. A root URL health check can
      // fail even while the API endpoints are available, leaving the app empty
      // until the user manually refreshes.
      await Future.wait([
        _loadAtStartup('categories', getAllCategory),
        _loadAtStartup('subcategories', getAllSubCategory),
        _loadAtStartup('brands', getAllBrands),
        _loadAtStartup('products', getAllProduct),
        _loadAtStartup('posters', getAllPosters),
        _loadAtStartup('store settings', getStoreSettings),
        _loadAtStartup('retailer contacts', getRetailerContacts),
        _loadAtStartup('video stories', getPublishedStories),
      ]);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAtStartup(
    String resource,
    Future<Object?> Function() load,
  ) async {
    for (var attempt = 1; attempt <= 2; attempt++) {
      try {
        await load();
        return;
      } catch (error) {
        if (attempt == 2) {
          debugPrint('Could not load $resource at startup: $error');
          return;
        }
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }
  }

  void _throwIfRequestFailed(Response response, ApiResponse<dynamic> result) {
    if ((response.statusCode ?? 500) >= 400 || !result.success) {
      throw Exception(result.message.isNotEmpty
          ? result.message
          : 'The server could not load this data.');
    }
  }

  void _loadPreferences() {
    try {
      _isDarkMode = box.read('isDarkMode') ?? false;
      _currentLanguage = box.read('language')?.toString() ?? 'en';

      if (!AppLocalizations.supportedLocales.any(
        (locale) => locale.languageCode == _currentLanguage,
      )) {
        _currentLanguage = 'en';
      }
    } catch (e) {
      _isDarkMode = false;
      _currentLanguage = 'en';
    }
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    box.write('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  void changeLanguage(String languageCode) {
    if (AppLocalizations.supportedLocales.any(
      (locale) => locale.languageCode == languageCode,
    )) {
      _currentLanguage = languageCode;
      box.write('language', languageCode);

      notifyListeners();
    }
  }

  String _fixImageUrl(String? url) {
    return resolveMediaUrl(url);
  }

  Future<List<StoreCollection>> getAllCollections() async {
    _isCollectionsLoading = true;
    _collectionsFailedToLoad = false;
    notifyListeners();
    try {
      final response = await service.getItems(endpointUrl: 'collections');
      final apiResponse = ApiResponse<List<StoreCollection>>.fromJson(
        response.body,
        (json) => (json as List)
            .map((item) => StoreCollection.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList(),
      );
      _throwIfRequestFailed(response, apiResponse);
      _collections = apiResponse.data ?? [];
      return _collections;
    } catch (error) {
      _collectionsFailedToLoad = true;
      debugPrint('Could not load collections: $error');
      return _collections;
    } finally {
      _isCollectionsLoading = false;
      notifyListeners();
    }
  }

  Future<StoreSettings> getStoreSettings() async {
    try {
      final response = await service.getItems(endpointUrl: 'store-settings');
      final apiResponse = ApiResponse<StoreSettings>.fromJson(
        response.body,
        (json) =>
            StoreSettings.fromJson(Map<String, dynamic>.from(json as Map)),
      );
      _throwIfRequestFailed(response, apiResponse);
      if (apiResponse.data == null) {
        throw StateError(
            'Store settings are missing from the server response.');
      }
      _storeSettings = apiResponse.data!;
      _hasLoadedStoreSettings = true;
      return _storeSettings;
    } catch (error) {
      _storeSettings = StoreSettings.defaults;
      _hasLoadedStoreSettings = false;
      debugPrint('Could not load store settings: $error');
      return _storeSettings;
    } finally {
      notifyListeners();
    }
  }

  Future<List<RetailerContact>> getRetailerContacts() async {
    _isRetailerContactsLoading = true;
    _retailerContactsError = null;
    notifyListeners();
    try {
      final response = await service.getItems(endpointUrl: 'retailer-contacts');
      final apiResponse = ApiResponse<List<RetailerContact>>.fromJson(
        response.body,
        (json) => (json as List)
            .whereType<Map>()
            .map((item) => RetailerContact.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .toList(),
      );
      _throwIfRequestFailed(response, apiResponse);
      // The API sorts ties by its stable document key. Keep the returned order
      // rather than re-sorting ties in the client without those keys.
      _retailerContacts = apiResponse.data ?? [];
      return _retailerContacts;
    } catch (_) {
      _retailerContactsError = 'Contact options are temporarily unavailable.';
      return _retailerContacts;
    } finally {
      _isRetailerContactsLoading = false;
      notifyListeners();
    }
  }

  // API methods with loading states
  Future<List<Product>> getAllProduct({bool showSnack = false}) async {
    try {
      _isProductsLoading = true;
      notifyListeners();

      Response response = await service.getItems(endpointUrl: 'products');
      ApiResponse<List<Product>> apiResponse = ApiResponse.fromJson(
        response.body,
        (json) => (json as List).map((item) {
          var productJson = Map<String, dynamic>.from(item);
          if (productJson['images'] != null) {
            var images = (productJson['images'] as List).map((image) {
              var imageMap = Map<String, dynamic>.from(image);
              if (imageMap['url'] != null) {
                imageMap['url'] = _fixImageUrl(imageMap['url']);
              }
              return imageMap;
            }).toList();
            productJson['images'] = images;
          }
          return Product.fromJson(productJson);
        }).toList(),
      );
      _throwIfRequestFailed(response, apiResponse);
      _allProducts = apiResponse.data ?? [];
      _filteredProducts = List.from(_allProducts);

      if (showSnack) {
        SnackBarHelper.showSuccessSnackBar(SnackBarHelper.localized(
            (s) => s.success,
            fallback: apiResponse.message));
      }
    } catch (e) {
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar(SnackBarHelper.localized(
            (s) => s.general_retry,
            fallback: 'We could not complete that. Please try again.'));
      }
      rethrow;
    } finally {
      _isProductsLoading = false;
      notifyListeners();
    }
    return _filteredProducts;
  }

  // NEW: getAllOrders - fetch all orders and keep them in provider
  Future<List<Order>> getAllOrders({bool showSnack = false}) async {
    try {
      final userJson = box.read(userInfoBox);
      final userId =
          userJson is Map<String, dynamic> ? userJson['_id']?.toString() : null;

      if (userId == null || userId.isEmpty) {
        _allOrders = [];
        _filteredOrders = [];
        notifyListeners();
        return _filteredOrders;
      }

      Response response = await service.getItems(
        endpointUrl: 'orders/orderByUserId/$userId',
      );
      ApiResponse<List<Order>> apiResponse = ApiResponse.fromJson(
        response.body,
        (json) => (json as List).map((item) {
          return Order.fromJson(item);
        }).toList(),
      );
      _throwIfRequestFailed(response, apiResponse);

      _allOrders = apiResponse.data ?? [];
      _filteredOrders = List.from(_allOrders);

      if (showSnack) {
        SnackBarHelper.showSuccessSnackBar(SnackBarHelper.localized(
            (s) => s.success,
            fallback: apiResponse.message));
      }
    } catch (e) {
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar(SnackBarHelper.localized(
            (s) => s.general_retry,
            fallback: 'We could not complete that. Please try again.'));
      }
      rethrow;
    }
    notifyListeners();
    return _filteredOrders;
  }

  Future<List<Category>> getAllCategory({bool showSnack = false}) async {
    try {
      _isCategoriesLoading = true;
      notifyListeners();

      Response response = await service.getItems(endpointUrl: 'categories');
      ApiResponse<List<Category>> apiResponse = ApiResponse.fromJson(
        response.body,
        (json) => (json as List).map((item) {
          var categoryJson = Map<String, dynamic>.from(item);
          if (categoryJson['image'] != null) {
            categoryJson['image'] = _fixImageUrl(categoryJson['image']);
          }
          return Category.fromJson(categoryJson);
        }).toList(),
      );
      _throwIfRequestFailed(response, apiResponse);
      _allCategories = apiResponse.data ?? [];
      _filteredCategories = List.from(_allCategories);

      if (showSnack) {
        SnackBarHelper.showSuccessSnackBar(SnackBarHelper.localized(
            (s) => s.success,
            fallback: apiResponse.message));
      }
    } catch (e) {
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar(SnackBarHelper.localized(
            (s) => s.general_retry,
            fallback: 'We could not complete that. Please try again.'));
      }
      rethrow;
    } finally {
      _isCategoriesLoading = false;
      notifyListeners();
    }
    return _filteredCategories;
  }

  Future<List<Poster>> getAllPosters({bool showSnack = false}) async {
    try {
      _isPostersLoading = true;
      notifyListeners();

      Response response = await service.getItems(endpointUrl: 'posters');
      ApiResponse<List<Poster>> apiResponse = ApiResponse.fromJson(
        response.body,
        (json) => (json as List).map((item) {
          var posterJson = Map<String, dynamic>.from(item);
          if (posterJson['imageUrl'] != null) {
            posterJson['imageUrl'] = _fixImageUrl(posterJson['imageUrl']);
          }
          return Poster.fromJson(posterJson);
        }).toList(),
      );
      _throwIfRequestFailed(response, apiResponse);
      _allPosters = apiResponse.data ?? [];
      _filteredPosters = List.from(_allPosters);

      if (showSnack) {
        SnackBarHelper.showSuccessSnackBar(SnackBarHelper.localized(
            (s) => s.success,
            fallback: apiResponse.message));
      }
    } catch (e) {
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar(SnackBarHelper.localized(
            (s) => s.general_retry,
            fallback: 'We could not complete that. Please try again.'));
      }
      rethrow;
    } finally {
      _isPostersLoading = false;
      notifyListeners();
    }
    return _filteredPosters;
  }

  Future<List<Story>> getPublishedStories() async {
    _isStoriesLoading = true;
    _storiesError = null;
    notifyListeners();
    try {
      final response = await service.getItems(endpointUrl: 'stories/published');
      final apiResponse = ApiResponse<List<Story>>.fromJson(
        response.body,
        (json) => (json as List)
            .map((item) => Story.fromJson(Map<String, dynamic>.from(item)))
            .where((story) =>
                story.id.isNotEmpty &&
                isSafeStoryPlaybackUrl(story.playbackUrl))
            .toList(),
      );
      _throwIfRequestFailed(response, apiResponse);
      _stories = apiResponse.data ?? [];
      return _stories;
    } catch (error) {
      _storiesError = error.toString();
      rethrow;
    } finally {
      _isStoriesLoading = false;
      notifyListeners();
    }
  }

  void filterCategories(String keyword) {
    if (keyword.isEmpty) {
      _filteredCategories = List.from(_allCategories);
    } else {
      final lowcase = keyword.toLowerCase();
      _filteredCategories = _allCategories.where((category) {
        return (category.name ?? '').toLowerCase().contains(lowcase);
      }).toList();
    }
    notifyListeners();
  }

  Future<List<SubCategory>> getAllSubCategory({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'subCategories');
      ApiResponse<List<SubCategory>> apiResponse = ApiResponse.fromJson(
        response.body,
        (json) =>
            (json as List).map((item) => SubCategory.fromJson(item)).toList(),
      );
      _throwIfRequestFailed(response, apiResponse);
      _allSubCategories = apiResponse.data ?? [];
      _filteredSubCategories = List.from(_allSubCategories);
      notifyListeners();
      if (showSnack) {
        SnackBarHelper.showSuccessSnackBar(SnackBarHelper.localized(
            (s) => s.success,
            fallback: apiResponse.message));
      }
    } catch (e) {
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar(SnackBarHelper.localized(
            (s) => s.general_retry,
            fallback: 'We could not complete that. Please try again.'));
      }
      rethrow;
    }
    return _filteredSubCategories;
  }

  void filteredSubCategories(String keyword) {
    if (keyword.isEmpty) {
      _filteredSubCategories = List.from(_allSubCategories);
    } else {
      final lowcase = keyword.toLowerCase();
      _filteredSubCategories = _allSubCategories.where((subCategory) {
        return (subCategory.name ?? '').toLowerCase().contains(lowcase);
      }).toList();
    }
    notifyListeners();
  }

  Future<List<Brand>> getAllBrands({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'brands');
      ApiResponse<List<Brand>> apiResponse = ApiResponse.fromJson(
        response.body,
        (json) => (json as List).map((item) {
          final brandJson = Map<String, dynamic>.from(item as Map);
          brandJson['logoUrl'] = _fixImageUrl(brandJson['logoUrl']?.toString());
          return Brand.fromJson(brandJson);
        }).toList(),
      );
      _throwIfRequestFailed(response, apiResponse);
      _allBrands = apiResponse.data ?? [];
      _filteredBrands = List.from(_allBrands);
      notifyListeners();
      if (showSnack) {
        SnackBarHelper.showSuccessSnackBar(SnackBarHelper.localized(
            (s) => s.success,
            fallback: apiResponse.message));
      }
    } catch (e) {
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar(SnackBarHelper.localized(
            (s) => s.general_retry,
            fallback: 'We could not complete that. Please try again.'));
      }
      rethrow;
    }
    return _filteredBrands;
  }

  void filteredBrands(String keyword) {
    if (keyword.isEmpty) {
      _filteredBrands = List.from(_allBrands);
    } else {
      final lowcase = keyword.toLowerCase();
      _filteredBrands = _allBrands.where((brand) {
        return (brand.name ?? '').toLowerCase().contains(lowcase);
      }).toList();
    }
    notifyListeners();
  }

  void filterProducts(String keyword) {
    if (keyword.isEmpty) {
      _filteredProducts = List.from(_allProducts);
    } else {
      final lowcase = keyword.toLowerCase();

      _filteredProducts = _allProducts.where((product) {
        final productNameContainsKeyword =
            (product.name ?? '').toLowerCase().contains(lowcase);
        final categoryNameContainsKeyword =
            product.proCategoryId?.name?.toLowerCase().contains(lowcase) ??
                false;
        final subCategoryNameContainsKeyword =
            product.proSubCategoryId?.name?.toLowerCase().contains(lowcase) ??
                false;
        final brandNameContainsKeyword =
            product.proBrandId?.name?.toLowerCase().contains(lowcase) ?? false;

        return productNameContainsKeyword ||
            categoryNameContainsKeyword ||
            subCategoryNameContainsKeyword ||
            brandNameContainsKeyword;
      }).toList();
    }
    notifyListeners();
  }

  double calculateDiscountPercentage(num originalPrice, num? discountedPrice) {
    if (originalPrice <= 0) {
      throw ArgumentError('Original price must be greater than zero.');
    }

    num finalDiscountedPrice = discountedPrice ?? originalPrice;

    if (finalDiscountedPrice > originalPrice) {
      return originalPrice.toDouble();
    }

    double discount =
        ((originalPrice - finalDiscountedPrice) / originalPrice) * 100;

    return discount;
  }

  // Refresh all data
  Future<void> refreshAllData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.wait([
        getAllCategory(),
        getAllSubCategory(),
        getAllBrands(),
        getAllProduct(),
        getAllPosters(),
        getStoreSettings(),
        getRetailerContacts(),
        getPublishedStories(),
      ]);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
