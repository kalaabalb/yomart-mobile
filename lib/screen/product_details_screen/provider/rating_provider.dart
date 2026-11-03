import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../../models/api_response.dart';
import '../../../models/rating.dart';
import '../../../services/http_services.dart';
import '../../../utility/snack_bar_helper.dart';

class RatingProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final box = GetStorage();

  // Rating state
  final Map<String, RatingResponse> _productRatings = {};
  final Map<String, RatingStats> _productRatingStats = {};
  final Map<String, Rating?> _userRatings = {};
  bool _isLoading = false;

  // Getters
  bool get isLoading => _isLoading;
  Map<String, RatingResponse> get productRatings => _productRatings;
  Map<String, RatingStats> get productRatingStats => _productRatingStats;
  Map<String, Rating?> get userRatings => _userRatings;

  Future<RatingResponse?> getRatingsForProduct(String productId,
      {int page = 1, int limit = 10}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await service.getItems(
        endpointUrl: 'ratings/product/$productId?page=$page&limit=$limit',
      );

      if (response.isOk) {
        if (response.body is Map<String, dynamic>) {
          final responseMap = response.body as Map<String, dynamic>;
          final success = responseMap['success'] as bool? ?? false;

          if (success && responseMap['data'] != null) {
            final data = responseMap['data'] as Map<String, dynamic>;
            final ratingResponse = RatingResponse.fromJson(data);
            _productRatings[productId] = ratingResponse;
            notifyListeners();
            return ratingResponse;
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<RatingStats?> getRatingStats(String productId) async {
    try {
      final response = await service.getItems(
        endpointUrl: 'ratings/product/$productId/stats',
      );

      if (response.isOk) {
        if (response.body is Map<String, dynamic>) {
          final responseMap = response.body as Map<String, dynamic>;
          final success = responseMap['success'] as bool? ?? false;

          if (success && responseMap['data'] != null) {
            final data = responseMap['data'] as Map<String, dynamic>;
            final ratingStats = RatingStats.fromJson(data);
            _productRatingStats[productId] = ratingStats;
            notifyListeners();
            return ratingStats;
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

// Get user's rating for a product
  Future<Rating?> getUserRating(String productId, String userId) async {
    try {
      final response = await service.getItems(
        endpointUrl: 'ratings/product/$productId/user/$userId',
      );

      if (response.isOk) {
        final ApiResponse<Rating?> apiResponse = ApiResponse.fromJson(
          response.body,
          (json) => json != null
              ? Rating.fromJson(json as Map<String, dynamic>)
              : null,
        );

        if (apiResponse.success == true) {
          _userRatings[productId] = apiResponse.data;
          notifyListeners();
          return apiResponse.data;
        }
      } else if (response.statusCode == 404) {
        // 404 means no rating found - this is normal, not an error
        debugPrint(
            '🟡 [RATING] No rating found for user $userId on product $productId');
        _userRatings[productId] = null;
        notifyListeners();
        return null;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Submit a rating - REMOVED context parameter
  Future<bool> submitRating({
    required String productId,
    required String userId,
    required String userName,
    required int rating,
    String? review,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final ratingData = {
        'productId': productId,
        'userId': userId,
        'userName': userName,
        'rating': rating,
        if (review != null && review.isNotEmpty) 'review': review,
      };

      final response = await service.addItem(
        endpointUrl: 'ratings',
        itemData: ratingData,
      );

      if (response.isOk) {
        final ApiResponse apiResponse =
            ApiResponse.fromJson(response.body, null);

        if (apiResponse.success == true) {
          // Refresh the ratings for this product
          await getRatingsForProduct(productId);
          await getRatingStats(productId);
          _userRatings[productId] = Rating(
            productId: productId,
            userId: userId,
            userName: userName,
            rating: rating,
            review: review,
          );

          // Show success message using SnackBarHelper
          SnackBarHelper.showSuccessSnackBar(SnackBarHelper.localized(
            (s) => s.rating_submitted,
            fallback: apiResponse.message,
          ));
          return true;
        } else {
          SnackBarHelper.showErrorSnackBar(SnackBarHelper.localized(
            (s) => s.submit_rating_failed,
            fallback: apiResponse.message,
          ));
          return false;
        }
      }
      return false;
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(SnackBarHelper.localized(
        (s) => s.submit_rating_failed,
        fallback: 'Failed to submit rating',
      ));
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update a rating - REMOVED context parameter
  Future<bool> updateRating({
    required String ratingId,
    required int rating,
    String? review,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final ratingData = {
        'rating': rating,
        if (review != null) 'review': review,
      };

      final response = await service.updateItem(
        endpointUrl: 'ratings',
        itemId: ratingId,
        itemData: ratingData,
      );

      if (response.isOk) {
        final ApiResponse apiResponse =
            ApiResponse.fromJson(response.body, null);

        if (apiResponse.success == true) {
          // Find and update the local rating
          for (final productId in _productRatings.keys) {
            final ratings = _productRatings[productId]?.ratings;
            if (ratings != null) {
              final index = ratings.indexWhere((r) => r.sId == ratingId);
              if (index != -1) {
                ratings[index].rating = rating;
                ratings[index].review = review;
                break;
              }
            }
          }

          // Refresh stats
          final updatedRating = _userRatings.values.firstWhere(
            (r) => r?.sId == ratingId,
            orElse: () => null,
          );
          if (updatedRating != null) {
            await getRatingStats(updatedRating.productId!);
          }

          SnackBarHelper.showSuccessSnackBar(SnackBarHelper.localized(
            (s) => s.rating_updated,
            fallback: apiResponse.message,
          ));
          return true;
        } else {
          SnackBarHelper.showErrorSnackBar(SnackBarHelper.localized(
            (s) => s.update_rating_failed,
            fallback: apiResponse.message,
          ));
          return false;
        }
      }
      return false;
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(SnackBarHelper.localized(
        (s) => s.update_rating_failed,
        fallback: 'Failed to update rating',
      ));
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a rating - REMOVED context parameter
  Future<bool> deleteRating({
    required String ratingId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await service.deleteItem(
        endpointUrl: 'ratings',
        itemId: ratingId,
      );

      if (response.isOk) {
        final ApiResponse apiResponse =
            ApiResponse.fromJson(response.body, null);

        if (apiResponse.success == true) {
          // Remove from local state
          for (final productId in _productRatings.keys) {
            final ratings = _productRatings[productId]?.ratings;
            if (ratings != null) {
              ratings.removeWhere((r) => r.sId == ratingId);
              break;
            }
          }

          // Remove user rating
          final deletedRatingKey = _userRatings.keys.firstWhere(
            (key) => _userRatings[key]?.sId == ratingId,
            orElse: () => '',
          );
          if (deletedRatingKey.isNotEmpty) {
            _userRatings.remove(deletedRatingKey);
          }

          // Refresh stats
          if (deletedRatingKey.isNotEmpty) {
            await getRatingStats(deletedRatingKey);
          }

          SnackBarHelper.showSuccessSnackBar(SnackBarHelper.localized(
            (s) => s.rating_deleted,
            fallback: apiResponse.message,
          ));
          return true;
        } else {
          SnackBarHelper.showErrorSnackBar(SnackBarHelper.localized(
            (s) => s.delete_rating_failed,
            fallback: apiResponse.message,
          ));
          return false;
        }
      }
      return false;
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(SnackBarHelper.localized(
        (s) => s.delete_rating_failed,
        fallback: 'Failed to delete rating',
      ));
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if user can rate a product (has purchased it)
  Future<bool> canUserRateProduct(String productId, String userId) async {
    // For now, we'll allow all users to rate
    // In a real app, you'd check if the user has purchased the product
    return true;
  }

  // Clear cache for a product
  void clearProductCache(String productId) {
    _productRatings.remove(productId);
    _productRatingStats.remove(productId);
    _userRatings.remove(productId);
    notifyListeners();
  }

  // Clear all cache
  void clearAllCache() {
    _productRatings.clear();
    _productRatingStats.clear();
    _userRatings.clear();
    notifyListeners();
  }
}
