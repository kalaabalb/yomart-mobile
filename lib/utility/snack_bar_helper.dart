import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../l10n/app_localizations.dart';

class SnackBarHelper {
  static AppLocalizations? get _strings {
    final context = Get.context;
    return context == null ? null : AppLocalizations.of(context);
  }

  /// Resolve provider notifications against the app's active locale without
  /// making providers depend on a particular screen's BuildContext.
  static String localized(
    String Function(AppLocalizations strings) resolve, {
    required String fallback,
  }) {
    final strings = _strings;
    return strings == null ? fallback : resolve(strings);
  }

  static String toUserFriendlyMessage(String message) =>
      _convertToUserFriendly(message);

  static void _showBubble({
    required String title,
    required String message,
    required IconData icon,
    required Color accent,
    required Duration duration,
  }) {
    Get.closeCurrentSnackbar();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      snackStyle: SnackStyle.FLOATING,
      backgroundColor: const Color(0xEE202127),
      colorText: Colors.white,
      duration: duration,
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      borderRadius: 28,
      barBlur: 14,
      animationDuration: const Duration(milliseconds: 240),
      isDismissible: true,
      shouldIconPulse: false,
      icon: Icon(icon, color: accent),
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFE6E6E8),
          fontSize: 13,
          height: 1.3,
        ),
      ),
    );
  }

  static void showSuccessSnackBar(String message) {
    _showBubble(
      title: _strings?.success ?? 'Success',
      message: message,
      icon: Icons.check_circle_outline,
      accent: const Color(0xFF6FE3A1),
      duration: const Duration(seconds: 3),
    );
  }

  static void showErrorSnackBar(String message) {
    // Convert technical errors to user-friendly messages
    String userMessage = _convertToUserFriendly(message);

    _showBubble(
      title: _strings?.something_went_wrong ?? 'Something went wrong',
      message: userMessage,
      icon: Icons.error_outline,
      accent: const Color(0xFFFF737B),
      duration: const Duration(seconds: 4),
    );
  }

  static void showInfoSnackBar(String message) {
    _showBubble(
      title: _strings?.info ?? 'Info',
      message: message,
      icon: Icons.info_outline,
      accent: const Color(0xFF82C9FF),
      duration: const Duration(seconds: 3),
    );
  }

  static void showProfileError(String error) {
    String userMessage = _convertProfileError(error);

    _showBubble(
      title: _strings?.update_failed ?? 'Update failed',
      message: userMessage,
      icon: Icons.warning_amber_rounded,
      accent: const Color(0xFFFFC06A),
      duration: const Duration(seconds: 4),
    );
  }

  static String _convertToUserFriendly(String error) {
    error = error.toLowerCase();

    if (error.contains('invalid name or password') ||
        error.contains('invalid username or password') ||
        error.contains('incorrect password')) {
      return localized((s) => s.wrong_credentials,
          fallback: 'Wrong username or password. Please try again.');
    }

    if (error.contains('email already registered') ||
        error.contains('email already exists') ||
        error.contains('email is already registered')) {
      return localized((s) => s.email_already_registered,
          fallback:
              'This email already has an account. Sign in or use a different email.');
    }

    if (error.contains('verification code') || error.contains('that code')) {
      if (error.contains('expired')) {
        return localized((s) => s.verification_code_expired,
            fallback:
                'That code has expired. Request a new one and try again.');
      }
      if (error.contains('too many')) {
        return localized((s) => s.too_many_code_attempts,
            fallback:
                'There were too many attempts. Wait a little, request a new code, and try again.');
      }
      if (error.contains('could not send') ||
          error.contains('failed to send')) {
        return localized((s) => s.resend_verification,
            fallback:
                'We couldn’t send the code. Tap Resend code to try again. If it keeps failing, contact support.');
      }
      if (error.contains('doesn’t match') || error.contains('doesn\'t match')) {
        return localized((s) => s.verification_code_mismatch,
            fallback:
                'That code does not match. Check the email and try again.');
      }
    }

    if (error.contains('please wait a minute')) {
      return localized((s) => s.wait_before_resend,
          fallback: 'Please wait a minute before asking for another code.');
    }

    if (error.contains('email verification is temporarily unavailable')) {
      return localized((s) => s.verification_email_unavailable,
          fallback:
              'We can’t send a verification email right now. Please try again later.');
    }

    if (error.contains('too many incorrect attempts')) {
      return localized((s) => s.too_many_incorrect_codes,
          fallback:
              'There were too many incorrect codes. Request a new one and try again.');
    }

    if (error.contains('verify your email')) {
      return localized((s) => s.verify_email_first,
          fallback:
              'Please verify your email address before creating your account.');
    }

    if (error.contains('server error') ||
        error.contains('internal server error') ||
        error.contains('status: 500')) {
      return localized((s) => s.server_error_retry,
          fallback:
              'Something went wrong on our side. Please try again in a moment.');
    }

    if (error.contains('already exists') ||
        error.contains('duplicate') ||
        error.contains('username is already taken')) {
      return localized((s) => s.username_taken,
          fallback:
              'This username is already taken. Please choose another one.');
    }

    if (error.contains('network error') ||
        error.contains('socket') ||
        error.contains('connection')) {
      return localized((s) => s.connection_error,
          fallback:
              'Cannot connect to server. Please check your internet connection.');
    }

    if (error.contains('timeout') || error.contains('timed out')) {
      return localized((s) => s.request_timeout,
          fallback: 'Request timeout. Please try again.');
    }

    if (error.contains('no response') ||
        error.contains('server not responding')) {
      return localized((s) => s.server_not_responding,
          fallback: 'Server is not responding. Please try again later.');
    }

    if (error.contains('required')) {
      if (error.contains('name') && error.contains('password')) {
        return localized((s) => s.both_credentials_required,
            fallback: 'Both username and password are required.');
      } else if (error.contains('name')) {
        return 'Username is required.';
      } else if (error.contains('password')) {
        return localized((s) => s.password_required,
            fallback: 'Password is required.');
      }
    }

    if (error.contains('could not send') || error.contains('failed to send')) {
      return 'We could not complete that right now. Please try again later.';
    }

    // Unknown server or programming details should not be shown to customers.
    return localized((s) => s.general_retry,
        fallback: 'We could not complete that. Please try again.');
  }

  static String _convertProfileError(String error) {
    error = error.toLowerCase();

    if (error.contains('current password is incorrect') ||
        error.contains('wrong current password')) {
      return localized((s) => s.current_password_incorrect,
          fallback: 'Your current password is incorrect. Please try again.');
    }

    if (error.contains('current password is required')) {
      return localized((s) => s.enter_current_password,
          fallback: 'Please enter your current password to make changes.');
    }

    if (error.contains('name is required')) {
      return localized((s) => s.username_cannot_empty,
          fallback: 'Username cannot be empty.');
    }

    if (error.contains('username is already taken') ||
        error.contains('name already exists')) {
      return localized((s) => s.choose_different_username,
          fallback:
              'This username is already taken. Please choose a different one.');
    }

    // Fall back to general error converter
    return _convertToUserFriendly(error);
  }
}
