import 'dart:async';
import 'dart:io';
import 'package:e_commerce_flutter/screen/home_screen.dart';
import 'package:e_commerce_flutter/screen/profile_screen/provider/profile_provider.dart';
import 'package:e_commerce_flutter/utility/snack_bar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cart/cart.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../models/user.dart';
import '../../../services/http_services.dart';
import '../login_screen.dart';
import '../../../utility/constants.dart';

class UserProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final box = GetStorage();

  UserProvider();

  User? getLoginUsr() {
    final token = box.read('auth_token');
    if (token == null || token.toString().isEmpty) {
      return null;
    }

    Map<String, dynamic>? userJson = box.read(userInfoBox);

    if (userJson == null || userJson.isEmpty) {
      return null;
    }

    try {
      User? userLogged = User.fromJson(userJson);
      return userLogged;
    } catch (e) {
      return null;
    }
  }

  Future<void> loginUser(String username, String password) async {
    try {
      Map<String, dynamic> loginData = {
        'name': username.toLowerCase().trim(),
        'password': password,
      };

      final response = await service.addItem(
        endpointUrl: 'users/login',
        itemData: loginData,
      );

      if (response.isOk) {
        final responseBody = response.body as Map<String, dynamic>;
        final success = responseBody['success'] ?? false;
        final message = responseBody['message'] ?? 'Login successful';
        final data = responseBody['data'];

        if (success && data != null) {
          final loginData = data as Map<String, dynamic>;
          final token = loginData['token']?.toString();
          final userJson = loginData['user'] is Map<String, dynamic>
              ? loginData['user'] as Map<String, dynamic>
              : loginData;
          User user = User.fromJson(userJson);

          if (token == null || token.isEmpty) {
            throw Exception(
                'Authentication token missing from login response.');
          }

          clearAllUserData();
          await saveLoginInfo(user, token: token);

          SnackBarHelper.showSuccessSnackBar(SnackBarHelper.localized(
            (s) => s.welcome_user(user.name ?? s.user),
            fallback: 'Welcome back, ${user.name ?? 'User'}!',
          ));
          Get.offAll(const HomeScreen());
        } else {
          throw Exception(message);
        }
      } else {
        if (response.statusCode == 401) {
          throw Exception('Invalid name or password.');
        } else if (response.statusCode == 404) {
          throw Exception('User not found.');
        } else {
          throw Exception('Login failed: ${response.statusText}');
        }
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
  }

  Future<void> registerUser(String name, String email, String password) async {
    try {
      Map<String, dynamic> user = {
        "name": name.toLowerCase().trim(),
        "email": email.toLowerCase().trim(),
        "password": password,
      };

      final response = await service.addItem(
        endpointUrl: 'users/register',
        itemData: user,
      );

      final responseBody = response.body;
      if (!response.isOk ||
          responseBody is! Map ||
          responseBody['success'] != true) {
        final message =
            responseBody is Map ? responseBody['message']?.toString() : null;
        throw Exception(message ?? 'We could not create your account.');
      }

      final data = responseBody['data'];
      if (data is! Map || data['user'] is! Map) {
        throw Exception(
            'Your account was created, but sign-in could not finish. Please try signing in.');
      }
      final token = data['token']?.toString();
      if (token == null || token.isEmpty) {
        throw Exception(
            'Your account was created, but sign-in could not finish. Please try signing in.');
      }

      final registeredUser =
          User.fromJson(Map<String, dynamic>.from(data['user'] as Map));
      await saveLoginInfo(registeredUser, token: token);
      SnackBarHelper.showSuccessSnackBar(SnackBarHelper.localized(
        (s) => s.welcome_user(registeredUser.name ?? s.user),
        fallback: 'Your account is ready. Welcome, ${registeredUser.name}!',
      ));
      Get.offAll(const HomeScreen());
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(e.toString());
      rethrow;
    }
  }

  Future<bool> updateProfile({
    required String userId,
    required String name,
    required String currentPassword,
    String? newPassword,
  }) async {
    bool isLoadingDialogShown = false;

    try {
      if (name.isEmpty) {
        SnackBarHelper.showProfileError(SnackBarHelper.localized(
          (s) => s.username_cannot_empty,
          fallback: 'Username cannot be empty',
        ));
        return false;
      }

      if (currentPassword.isEmpty) {
        SnackBarHelper.showProfileError(SnackBarHelper.localized(
          (s) => s.current_password_required,
          fallback: 'Current password is required',
        ));
        return false;
      }

      if (Get.isDialogOpen == false) {
        Get.dialog(
          const Center(
            child: CircularProgressIndicator(),
          ),
          barrierDismissible: false,
        );
        isLoadingDialogShown = true;
      }

      Map<String, dynamic> updateData = {
        'name': name.trim(),
        'currentPassword': currentPassword,
      };

      if (newPassword != null && newPassword.isNotEmpty) {
        if (newPassword.length < 4) {
          _closeLoadingDialog(isLoadingDialogShown);
          SnackBarHelper.showProfileError(
              'New password must be at least 4 characters');
          return false;
        }
        updateData['password'] = newPassword;
      }

      final response = await service.updateItem(
        endpointUrl: 'users/profile',
        itemId: '',
        itemData: updateData,
      );

      _closeLoadingDialog(isLoadingDialogShown);

      if (response.isOk) {
        final responseBody = response.body as Map<String, dynamic>;
        final success = responseBody['success'] ?? false;
        final message = responseBody['message'] ?? 'Profile updated';

        if (success) {
          final data = responseBody['data'];

          if (data != null && data is Map<String, dynamic>) {
            final updatedUser = User.fromJson(data);
            final storedToken = box.read('auth_token')?.toString();
            await saveLoginInfo(updatedUser, token: storedToken);

            notifyListeners();

            SnackBarHelper.showSuccessSnackBar(SnackBarHelper.localized(
                (s) => s.profile_updated,
                fallback: 'Profile updated successfully!'));

            if (newPassword != null && newPassword.isNotEmpty) {
              SnackBarHelper.showSuccessSnackBar(
                SnackBarHelper.localized((s) => s.password_updated_relogin,
                    fallback:
                        'Password updated successfully. Please login again.'),
              );

              Future.delayed(const Duration(seconds: 2), () {
                logOutUser();
              });
            }

            return true;
          }

          SnackBarHelper.showProfileError(SnackBarHelper.localized(
            (s) => s.update_failed,
            fallback: 'Profile update returned no data',
          ));
          return false;
        } else {
          SnackBarHelper.showProfileError(message);
          return false;
        }
      } else {
        SnackBarHelper.showProfileError(
            'Update failed: ${response.statusText}');
        return false;
      }
    } catch (e) {
      _closeLoadingDialog(isLoadingDialogShown);
      debugPrint('❌ Profile update error: $e');
      SnackBarHelper.showProfileError(SnackBarHelper.localized(
        (s) => s.an_error_occurred,
        fallback: 'An error occurred',
      ));
      return false;
    }
  }

  void _closeLoadingDialog(bool wasShown) {
    if (wasShown && Get.isDialogOpen == true) {
      Get.back();
    }
  }

  Future<void> saveLoginInfo(User? loginUser, {String? token}) async {
    if (loginUser == null) return;
    try {
      await box.write(userInfoBox, loginUser.toJson());
      if (token != null && token.isNotEmpty) {
        await box.write('auth_token', token);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving login info: $e');
    }
  }

  void clearAllUserData() {
    try {
      box.remove('auth_token');
      box.remove(userInfoBox);

      box.remove(favoriteProductBox);

      var flutterCart = FlutterCart();
      flutterCart.clearCart();

      box.remove(phoneKey);
      box.remove(streetKey);
      box.remove(cityKey);
      box.remove(stateKey);
      box.remove(postalCodeKey);
      box.remove(countryKey);
      box.remove('savedDeliveryAddresses');
      box.remove('selectedDeliveryAddress');
      box.remove('LATITUDE_KEY');
      box.remove('LONGITUDE_KEY');

      box.remove('profileImagePath');

      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing user data: $e');
    }
  }

  void logOutUser() {
    try {
      if (Get.isRegistered<ProfileProvider>()) {
        final profileProvider = Get.find<ProfileProvider>();
        profileProvider.clearProfileData();
      }

      clearAllUserData();
      Get.offAll(const LoginScreen());
      SnackBarHelper.showInfoSnackBar(SnackBarHelper.localized(
        (s) => s.logged_out,
        fallback: 'Logged out successfully',
      ));
      notifyListeners();
    } catch (e) {
      debugPrint('Error during logout: $e');
      Get.offAll(const LoginScreen());
    }
  }

  Future<bool> deleteAccount(String currentPassword) async {
    try {
      final response = await service.deleteItem(
        endpointUrl: 'users/account',
        itemId: '',
        itemData: {'currentPassword': currentPassword},
      );
      final body = response.body;
      if (!response.isOk || body is! Map || body['success'] != true) {
        final message = body is Map ? body['message']?.toString() : null;
        throw Exception(message ?? 'We could not delete your account.');
      }

      if (Get.isRegistered<ProfileProvider>()) {
        final profileProvider = Get.find<ProfileProvider>();
        final imagePath = profileProvider.profileImagePath;
        profileProvider.clearProfileData();
        if (imagePath != null) {
          await File(imagePath).delete().catchError((_) => File(imagePath));
        }
      }
      clearAllUserData();
      Get.offAll(const LoginScreen());
      SnackBarHelper.showSuccessSnackBar(SnackBarHelper.localized(
        (s) => s.account_deleted_success,
        fallback: 'Your account and associated data have been deleted.',
      ));
      return true;
    } catch (error) {
      SnackBarHelper.showErrorSnackBar(error.toString());
      return false;
    }
  }

  Future<void> restoreSession() async {
    final token = box.read('auth_token');
    final userJson = box.read(userInfoBox);

    if (token == null || token.toString().isEmpty || userJson == null) {
      clearAllUserData();
      return;
    }

    try {
      final response = await service.getItems(endpointUrl: 'users/profile');
      if (response.statusCode == 401) {
        clearAllUserData();
        Get.offAll(const LoginScreen());
        return;
      }

      if (response.isOk) {
        final responseBody = response.body as Map<String, dynamic>;
        final data = responseBody['data'];

        if (data is Map<String, dynamic>) {
          await saveLoginInfo(User.fromJson(data), token: token.toString());
          return;
        }
      }
    } catch (e) {
      return;
    }
  }
}
