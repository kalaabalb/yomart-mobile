import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en'),
    Locale('es'),
    Locale('fr')
  ];

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get welcome;

  /// No description provided for @welcome_back.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcome_back;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @get_something.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get something!'**
  String get get_something;

  /// No description provided for @get_now.
  ///
  /// In en, this message translates to:
  /// **'Get Now'**
  String get get_now;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @enter_username.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get enter_username;

  /// No description provided for @enter_password.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enter_password;

  /// No description provided for @confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirm_password;

  /// No description provided for @passwords_dont_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwords_dont_match;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @dont_have_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get dont_have_account;

  /// No description provided for @already_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get already_have_account;

  /// No description provided for @total_amount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get total_amount;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @grand_total.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get grand_total;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @complete_order.
  ///
  /// In en, this message translates to:
  /// **'Complete Order'**
  String get complete_order;

  /// No description provided for @buy_now.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get buy_now;

  /// No description provided for @enter_address.
  ///
  /// In en, this message translates to:
  /// **'Enter Address'**
  String get enter_address;

  /// No description provided for @payment_method.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get payment_method;

  /// No description provided for @sort_by_price.
  ///
  /// In en, this message translates to:
  /// **'Sort By Price'**
  String get sort_by_price;

  /// No description provided for @low_to_high.
  ///
  /// In en, this message translates to:
  /// **'Low To High'**
  String get low_to_high;

  /// No description provided for @high_to_low.
  ///
  /// In en, this message translates to:
  /// **'High To Low'**
  String get high_to_low;

  /// No description provided for @filter_by_brands.
  ///
  /// In en, this message translates to:
  /// **'Filter By Brands'**
  String get filter_by_brands;

  /// No description provided for @available_stock.
  ///
  /// In en, this message translates to:
  /// **'Available stock'**
  String get available_stock;

  /// No description provided for @not_available.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get not_available;

  /// No description provided for @add_to_cart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get add_to_cart;

  /// No description provided for @no_favorite_items.
  ///
  /// In en, this message translates to:
  /// **'No favorite items yet'**
  String get no_favorite_items;

  /// No description provided for @empty_cart.
  ///
  /// In en, this message translates to:
  /// **'Empty cart'**
  String get empty_cart;

  /// No description provided for @my_account.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get my_account;

  /// No description provided for @my_profile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get my_profile;

  /// No description provided for @edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile;

  /// No description provided for @delivery_information.
  ///
  /// In en, this message translates to:
  /// **'Destination Information'**
  String get delivery_information;

  /// No description provided for @order_history.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get order_history;

  /// No description provided for @my_orders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get my_orders;

  /// No description provided for @my_address.
  ///
  /// In en, this message translates to:
  /// **'My Address'**
  String get my_address;

  /// No description provided for @my_favorites.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get my_favorites;

  /// No description provided for @my_cart.
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get my_cart;

  /// No description provided for @member_since.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get member_since;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacy_security.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacy_security;

  /// No description provided for @about_app.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get about_app;

  /// No description provided for @help_support.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get help_support;

  /// No description provided for @email_support.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get email_support;

  /// No description provided for @call_support.
  ///
  /// In en, this message translates to:
  /// **'Call Support'**
  String get call_support;

  /// No description provided for @live_chat.
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get live_chat;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logout_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logout_confirmation;

  /// No description provided for @delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get delete_account;

  /// No description provided for @delete_account_confirmation.
  ///
  /// In en, this message translates to:
  /// **'This disables your account and removes profile, contact, delivery details, and reviews. Order and payment evidence may be retained in anonymized form for business records. Enter your password to confirm.'**
  String get delete_account_confirmation;

  /// No description provided for @account_deleted_success.
  ///
  /// In en, this message translates to:
  /// **'Your account access and direct details were removed. Anonymized order and payment records are retained.'**
  String get account_deleted_success;

  /// No description provided for @privacy_policy_not_configured.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy is not configured for this build.'**
  String get privacy_policy_not_configured;

  /// No description provided for @privacy_policy_open_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the privacy policy. Please try again.'**
  String get privacy_policy_open_failed;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @update_address.
  ///
  /// In en, this message translates to:
  /// **'Update Address'**
  String get update_address;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @street.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get street;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @postal_code.
  ///
  /// In en, this message translates to:
  /// **'Postal Code (Optional)'**
  String get postal_code;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @please_enter_phone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a phone number'**
  String get please_enter_phone;

  /// No description provided for @please_enter_street.
  ///
  /// In en, this message translates to:
  /// **'Please enter a street'**
  String get please_enter_street;

  /// No description provided for @please_enter_city.
  ///
  /// In en, this message translates to:
  /// **'Please enter a city'**
  String get please_enter_city;

  /// No description provided for @please_enter_state.
  ///
  /// In en, this message translates to:
  /// **'Please enter a state'**
  String get please_enter_state;

  /// No description provided for @please_enter_code.
  ///
  /// In en, this message translates to:
  /// **'Please enter a code'**
  String get please_enter_code;

  /// No description provided for @please_enter_country.
  ///
  /// In en, this message translates to:
  /// **'Please enter a country'**
  String get please_enter_country;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get dark_mode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @select_language.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get select_language;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'HELP & SUPPORT'**
  String get help;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @payment_successful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get payment_successful;

  /// No description provided for @payment_failed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get payment_failed;

  /// No description provided for @order_created.
  ///
  /// In en, this message translates to:
  /// **'Order created successfully!'**
  String get order_created;

  /// No description provided for @address_stored.
  ///
  /// In en, this message translates to:
  /// **'Address stored successfully'**
  String get address_stored;

  /// No description provided for @item_added_to_cart.
  ///
  /// In en, this message translates to:
  /// **'Item added to cart'**
  String get item_added_to_cart;

  /// No description provided for @please_select_variant.
  ///
  /// In en, this message translates to:
  /// **'Please select a variant'**
  String get please_select_variant;

  /// No description provided for @search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search_hint;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @please_fill_all_fields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get please_fill_all_fields;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @top_categories.
  ///
  /// In en, this message translates to:
  /// **'Top Categories'**
  String get top_categories;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @track_order.
  ///
  /// In en, this message translates to:
  /// **'Track Order'**
  String get track_order;

  /// No description provided for @discover_products.
  ///
  /// In en, this message translates to:
  /// **'Discover Amazing Products'**
  String get discover_products;

  /// No description provided for @products_heading.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products_heading;

  /// No description provided for @easy_shopping.
  ///
  /// In en, this message translates to:
  /// **'Easy & Secure Shopping'**
  String get easy_shopping;

  /// No description provided for @fast_delivery.
  ///
  /// In en, this message translates to:
  /// **'Fast Delivery'**
  String get fast_delivery;

  /// No description provided for @start_shopping.
  ///
  /// In en, this message translates to:
  /// **'Start Shopping Now!'**
  String get start_shopping;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @get_started.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get get_started;

  /// No description provided for @customer_reviews.
  ///
  /// In en, this message translates to:
  /// **'Customer Reviews'**
  String get customer_reviews;

  /// No description provided for @change_password.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get change_password;

  /// No description provided for @current_password.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get current_password;

  /// No description provided for @new_password.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get new_password;

  /// No description provided for @confirm_new_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirm_new_password;

  /// No description provided for @profile_change_note.
  ///
  /// In en, this message translates to:
  /// **'Note: Changing email requires verification. Changing your username or password will sign you out.'**
  String get profile_change_note;

  /// No description provided for @email_not_verified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified'**
  String get email_not_verified;

  /// No description provided for @cart_empty_message.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cart_empty_message;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @item_removed.
  ///
  /// In en, this message translates to:
  /// **'Item removed from cart'**
  String get item_removed;

  /// No description provided for @item_added.
  ///
  /// In en, this message translates to:
  /// **'Item added to cart'**
  String get item_added;

  /// No description provided for @cart_updated.
  ///
  /// In en, this message translates to:
  /// **'Cart updated'**
  String get cart_updated;

  /// No description provided for @cash_on_delivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get cash_on_delivery;

  /// No description provided for @cbe_bank.
  ///
  /// In en, this message translates to:
  /// **'Commercial Bank of Ethiopia'**
  String get cbe_bank;

  /// No description provided for @telebirr.
  ///
  /// In en, this message translates to:
  /// **'Telebirr'**
  String get telebirr;

  /// No description provided for @order_processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get order_processing;

  /// No description provided for @order_shipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get order_shipped;

  /// No description provided for @order_delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get order_delivered;

  /// No description provided for @order_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get order_cancelled;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @continue_shopping.
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get continue_shopping;

  /// No description provided for @view_orders.
  ///
  /// In en, this message translates to:
  /// **'View Orders'**
  String get view_orders;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @load_more_reviews.
  ///
  /// In en, this message translates to:
  /// **'Load More Reviews'**
  String get load_more_reviews;

  /// No description provided for @no_reviews_yet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet. Be the first to review this product!'**
  String get no_reviews_yet;

  /// No description provided for @anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// No description provided for @verified_purchase.
  ///
  /// In en, this message translates to:
  /// **'Verified Purchase'**
  String get verified_purchase;

  /// No description provided for @rate_this_product.
  ///
  /// In en, this message translates to:
  /// **'Rate this product'**
  String get rate_this_product;

  /// No description provided for @your_rating.
  ///
  /// In en, this message translates to:
  /// **'Your Rating'**
  String get your_rating;

  /// No description provided for @delete_rating.
  ///
  /// In en, this message translates to:
  /// **'Delete Rating'**
  String get delete_rating;

  /// No description provided for @delete_rating_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your rating?'**
  String get delete_rating_confirmation;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @review_optional.
  ///
  /// In en, this message translates to:
  /// **'Review (optional)'**
  String get review_optional;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @available_options.
  ///
  /// In en, this message translates to:
  /// **'Available options'**
  String get available_options;

  /// No description provided for @product_details.
  ///
  /// In en, this message translates to:
  /// **'Product details'**
  String get product_details;

  /// No description provided for @telegram_support.
  ///
  /// In en, this message translates to:
  /// **'Telegram Support'**
  String get telegram_support;

  /// No description provided for @welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome_title;

  /// No description provided for @create_account.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get create_account;

  /// No description provided for @login_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your journey.'**
  String get login_subtitle;

  /// No description provided for @register_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Join YoMart and start shopping.'**
  String get register_subtitle;

  /// No description provided for @email_address.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get email_address;

  /// No description provided for @password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password_label;

  /// No description provided for @password_requirements.
  ///
  /// In en, this message translates to:
  /// **'Complete the password requirements below.'**
  String get password_requirements;

  /// No description provided for @confirm_your_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password.'**
  String get confirm_your_password;

  /// No description provided for @sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get sign_in;

  /// No description provided for @dont_have_account_prompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dont_have_account_prompt;

  /// No description provided for @already_have_account_prompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get already_have_account_prompt;

  /// No description provided for @all_filter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all_filter;

  /// No description provided for @phones_filter.
  ///
  /// In en, this message translates to:
  /// **'Phones'**
  String get phones_filter;

  /// No description provided for @brands_filter.
  ///
  /// In en, this message translates to:
  /// **'Brands'**
  String get brands_filter;

  /// No description provided for @accessories_filter.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get accessories_filter;

  /// No description provided for @search_catalog.
  ///
  /// In en, this message translates to:
  /// **'Search phones, brands, accessories...'**
  String get search_catalog;

  /// No description provided for @clear_search.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clear_search;

  /// No description provided for @no_products_available.
  ///
  /// In en, this message translates to:
  /// **'No products are available yet.'**
  String get no_products_available;

  /// No description provided for @no_search_matches.
  ///
  /// In en, this message translates to:
  /// **'No matches. Try another search.'**
  String get no_search_matches;

  /// No description provided for @trending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get trending;

  /// No description provided for @see_all.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get see_all;

  /// No description provided for @try_again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get try_again;

  /// No description provided for @collections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collections;

  /// No description provided for @best_sellers.
  ///
  /// In en, this message translates to:
  /// **'Best Sellers'**
  String get best_sellers;

  /// No description provided for @most_popular.
  ///
  /// In en, this message translates to:
  /// **'Most popular right now'**
  String get most_popular;

  /// No description provided for @new_arrivals.
  ///
  /// In en, this message translates to:
  /// **'New Arrivals'**
  String get new_arrivals;

  /// No description provided for @latest_models_trends.
  ///
  /// In en, this message translates to:
  /// **'Latest models and trends'**
  String get latest_models_trends;

  /// No description provided for @student_deals.
  ///
  /// In en, this message translates to:
  /// **'Student Deals'**
  String get student_deals;

  /// No description provided for @special_offers_students.
  ///
  /// In en, this message translates to:
  /// **'Special offers for students'**
  String get special_offers_students;

  /// No description provided for @accessories_bundle.
  ///
  /// In en, this message translates to:
  /// **'Accessories Bundle'**
  String get accessories_bundle;

  /// No description provided for @save_more_together.
  ///
  /// In en, this message translates to:
  /// **'Save more together'**
  String get save_more_together;

  /// No description provided for @no_collection_products.
  ///
  /// In en, this message translates to:
  /// **'No products in this collection yet.'**
  String get no_collection_products;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @confirm_location.
  ///
  /// In en, this message translates to:
  /// **'Confirm location'**
  String get confirm_location;

  /// No description provided for @delivery_location.
  ///
  /// In en, this message translates to:
  /// **'Delivery Location'**
  String get delivery_location;

  /// No description provided for @delivery_pin.
  ///
  /// In en, this message translates to:
  /// **'Destination pin'**
  String get delivery_pin;

  /// No description provided for @choose_on_map.
  ///
  /// In en, this message translates to:
  /// **'Choose on map'**
  String get choose_on_map;

  /// No description provided for @phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phone_number;

  /// No description provided for @street_building.
  ///
  /// In en, this message translates to:
  /// **'Street and building'**
  String get street_building;

  /// No description provided for @image_format_limit.
  ///
  /// In en, this message translates to:
  /// **'PNG, JPG (Max 5MB)'**
  String get image_format_limit;

  /// No description provided for @choose_different_image.
  ///
  /// In en, this message translates to:
  /// **'Choose a different image'**
  String get choose_different_image;

  /// No description provided for @processing_order.
  ///
  /// In en, this message translates to:
  /// **'Processing your order...'**
  String get processing_order;

  /// No description provided for @tracking_confirmation_pending.
  ///
  /// In en, this message translates to:
  /// **'Tracking will update after your order is confirmed.'**
  String get tracking_confirmation_pending;

  /// No description provided for @payment_details.
  ///
  /// In en, this message translates to:
  /// **'Payment Details'**
  String get payment_details;

  /// No description provided for @payment_proof.
  ///
  /// In en, this message translates to:
  /// **'Payment proof'**
  String get payment_proof;

  /// No description provided for @no_payment_proof.
  ///
  /// In en, this message translates to:
  /// **'No payment proof has been submitted yet.'**
  String get no_payment_proof;

  /// No description provided for @product_details_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Product details are unavailable.'**
  String get product_details_unavailable;

  /// No description provided for @product_details_unavailable_now.
  ///
  /// In en, this message translates to:
  /// **'Product details are unavailable right now.'**
  String get product_details_unavailable_now;

  /// No description provided for @profile_preferences_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Theme and language settings'**
  String get profile_preferences_tooltip;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @favorites_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites_tooltip;

  /// No description provided for @go_back.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get go_back;

  /// No description provided for @orders_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders_tooltip;

  /// No description provided for @refresh_cart.
  ///
  /// In en, this message translates to:
  /// **'Refresh cart'**
  String get refresh_cart;

  /// No description provided for @search_products.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get search_products;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @upload_proof.
  ///
  /// In en, this message translates to:
  /// **'Upload Proof'**
  String get upload_proof;

  /// No description provided for @confirm_payment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get confirm_payment;

  /// No description provided for @cash_payment_title.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery Payment'**
  String get cash_payment_title;

  /// No description provided for @cbe_payment_title.
  ///
  /// In en, this message translates to:
  /// **'Commercial Bank of Ethiopia Payment'**
  String get cbe_payment_title;

  /// No description provided for @telebirr_payment_title.
  ///
  /// In en, this message translates to:
  /// **'Telebirr Payment'**
  String get telebirr_payment_title;

  /// No description provided for @cbe_birr_app.
  ///
  /// In en, this message translates to:
  /// **'CBE Birr App'**
  String get cbe_birr_app;

  /// No description provided for @bank_transfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bank_transfer;

  /// No description provided for @telebirr_app.
  ///
  /// In en, this message translates to:
  /// **'Telebirr App'**
  String get telebirr_app;

  /// No description provided for @catalog_refreshed.
  ///
  /// In en, this message translates to:
  /// **'Catalog refreshed.'**
  String get catalog_refreshed;

  /// No description provided for @favorites_refreshed.
  ///
  /// In en, this message translates to:
  /// **'Favorites refreshed.'**
  String get favorites_refreshed;

  /// No description provided for @could_not_launch_url.
  ///
  /// In en, this message translates to:
  /// **'Could not launch URL'**
  String get could_not_launch_url;

  /// No description provided for @please_wait.
  ///
  /// In en, this message translates to:
  /// **'Please wait…'**
  String get please_wait;

  /// No description provided for @user_not_found.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get user_not_found;

  /// No description provided for @an_error_occurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get an_error_occurred;

  /// No description provided for @username_required.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get username_required;

  /// No description provided for @current_password_required.
  ///
  /// In en, this message translates to:
  /// **'Current password is required for verification'**
  String get current_password_required;

  /// No description provided for @new_password_required.
  ///
  /// In en, this message translates to:
  /// **'New password is required'**
  String get new_password_required;

  /// No description provided for @passwords_do_not_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwords_do_not_match;

  /// No description provided for @password_confirm_mismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get password_confirm_mismatch;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @try_another_category.
  ///
  /// In en, this message translates to:
  /// **'Try another category or brand.'**
  String get try_another_category;

  /// No description provided for @no_products_match_filters.
  ///
  /// In en, this message translates to:
  /// **'No products match these filters'**
  String get no_products_match_filters;

  /// No description provided for @address_not_found.
  ///
  /// In en, this message translates to:
  /// **'Address not found'**
  String get address_not_found;

  /// No description provided for @select_variant.
  ///
  /// In en, this message translates to:
  /// **'Please select a variant'**
  String get select_variant;

  /// No description provided for @failed_add_item.
  ///
  /// In en, this message translates to:
  /// **'Failed to add item to cart'**
  String get failed_add_item;

  /// No description provided for @submit_rating_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit rating'**
  String get submit_rating_failed;

  /// No description provided for @update_rating_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update rating'**
  String get update_rating_failed;

  /// No description provided for @delete_rating_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete rating'**
  String get delete_rating_failed;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @something_went_wrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get something_went_wrong;

  /// No description provided for @update_failed.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get update_failed;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @place_order.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get place_order;

  /// No description provided for @order_status.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get order_status;

  /// No description provided for @payment_pending.
  ///
  /// In en, this message translates to:
  /// **'Payment Pending'**
  String get payment_pending;

  /// No description provided for @delivery_address.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get delivery_address;

  /// No description provided for @review_order.
  ///
  /// In en, this message translates to:
  /// **'Review Order'**
  String get review_order;

  /// No description provided for @payment_proof_upload.
  ///
  /// In en, this message translates to:
  /// **'Please upload your payment proof.'**
  String get payment_proof_upload;

  /// No description provided for @upload_payment_proof.
  ///
  /// In en, this message translates to:
  /// **'Upload Proof'**
  String get upload_payment_proof;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @phones.
  ///
  /// In en, this message translates to:
  /// **'Phones'**
  String get phones;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @brands.
  ///
  /// In en, this message translates to:
  /// **'Brands'**
  String get brands;

  /// No description provided for @email_or_username.
  ///
  /// In en, this message translates to:
  /// **'Email or username'**
  String get email_or_username;

  /// No description provided for @enter_a_username.
  ///
  /// In en, this message translates to:
  /// **'Enter a username.'**
  String get enter_a_username;

  /// No description provided for @username_min_length.
  ///
  /// In en, this message translates to:
  /// **'Use at least 3 characters for your username.'**
  String get username_min_length;

  /// No description provided for @email_format_hint.
  ///
  /// In en, this message translates to:
  /// **'Use the format {example}.'**
  String email_format_hint(String example);

  /// No description provided for @enter_email_address.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address.'**
  String get enter_email_address;

  /// No description provided for @invalid_email_format.
  ///
  /// In en, this message translates to:
  /// **'Enter an email in the format {example}.'**
  String invalid_email_format(String example);

  /// No description provided for @password_requirements_below.
  ///
  /// In en, this message translates to:
  /// **'Complete the password requirements below.'**
  String get password_requirements_below;

  /// No description provided for @passwords_do_not_match_hint.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwords_do_not_match_hint;

  /// No description provided for @signing_in.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get signing_in;

  /// No description provided for @creating_account.
  ///
  /// In en, this message translates to:
  /// **'Creating account…'**
  String get creating_account;

  /// No description provided for @eight_characters_count.
  ///
  /// In en, this message translates to:
  /// **'8+ characters ({count}/8)'**
  String eight_characters_count(String count);

  /// No description provided for @uppercase_and_lowercase.
  ///
  /// In en, this message translates to:
  /// **'uppercase and lowercase'**
  String get uppercase_and_lowercase;

  /// No description provided for @number_requirement.
  ///
  /// In en, this message translates to:
  /// **'number'**
  String get number_requirement;

  /// No description provided for @special_character_requirement.
  ///
  /// In en, this message translates to:
  /// **'special character'**
  String get special_character_requirement;

  /// No description provided for @sign_in_to_continue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your journey.'**
  String get sign_in_to_continue;

  /// No description provided for @join_and_shop.
  ///
  /// In en, this message translates to:
  /// **'Join YoMart and start shopping.'**
  String get join_and_shop;

  /// No description provided for @search_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get search_all;

  /// No description provided for @search_phones.
  ///
  /// In en, this message translates to:
  /// **'Phones'**
  String get search_phones;

  /// No description provided for @search_brands.
  ///
  /// In en, this message translates to:
  /// **'Brands'**
  String get search_brands;

  /// No description provided for @search_accessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get search_accessories;

  /// No description provided for @orders_tab.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders_tab;

  /// No description provided for @account_tab.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account_tab;

  /// No description provided for @email_example.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get email_example;

  /// No description provided for @no_ratings_yet.
  ///
  /// In en, this message translates to:
  /// **'No ratings yet'**
  String get no_ratings_yet;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @password_minimum_length.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get password_minimum_length;

  /// No description provided for @catalog_load_error.
  ///
  /// In en, this message translates to:
  /// **'Could not load the catalog. Check your connection and try again.'**
  String get catalog_load_error;

  /// No description provided for @catalog_unavailable.
  ///
  /// In en, this message translates to:
  /// **'The catalog isn’t available right now'**
  String get catalog_unavailable;

  /// No description provided for @check_connection_retry.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get check_connection_retry;

  /// No description provided for @order_number.
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String order_number(String id);

  /// No description provided for @placed_on.
  ///
  /// In en, this message translates to:
  /// **'Placed on {date}'**
  String placed_on(String date);

  /// No description provided for @submitted_on.
  ///
  /// In en, this message translates to:
  /// **'Submitted {date}'**
  String submitted_on(String date);

  /// No description provided for @tracking_reference.
  ///
  /// In en, this message translates to:
  /// **'Tracking reference: {reference}'**
  String tracking_reference(String reference);

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Qty: {quantity}'**
  String quantity(String quantity);

  /// No description provided for @stage_out_for_delivery.
  ///
  /// In en, this message translates to:
  /// **'At destination city'**
  String get stage_out_for_delivery;

  /// No description provided for @order_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get order_pending;

  /// No description provided for @awaiting_payment.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Payment'**
  String get awaiting_payment;

  /// No description provided for @payment_verified.
  ///
  /// In en, this message translates to:
  /// **'Payment Verified'**
  String get payment_verified;

  /// No description provided for @payment_paid.
  ///
  /// In en, this message translates to:
  /// **'Payment Paid'**
  String get payment_paid;

  /// No description provided for @payment_failed_status.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get payment_failed_status;

  /// No description provided for @recently.
  ///
  /// In en, this message translates to:
  /// **'recently'**
  String get recently;

  /// No description provided for @rating_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Rating'**
  String get rating_delete_title;

  /// No description provided for @rating_delete_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your rating?'**
  String get rating_delete_confirmation;

  /// No description provided for @orders_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Orders aren’t available'**
  String get orders_unavailable;

  /// No description provided for @no_orders_yet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get no_orders_yet;

  /// No description provided for @no_orders_for_filter.
  ///
  /// In en, this message translates to:
  /// **'No {status} orders'**
  String no_orders_for_filter(String status);

  /// No description provided for @orders_empty_message.
  ///
  /// In en, this message translates to:
  /// **'Your purchases and their status will appear here.'**
  String get orders_empty_message;

  /// No description provided for @curated_for_you.
  ///
  /// In en, this message translates to:
  /// **'Curated for you'**
  String get curated_for_you;

  /// No description provided for @tablets.
  ///
  /// In en, this message translates to:
  /// **'Tablets'**
  String get tablets;

  /// No description provided for @smartwatches.
  ///
  /// In en, this message translates to:
  /// **'Smartwatches'**
  String get smartwatches;

  /// No description provided for @laptops.
  ///
  /// In en, this message translates to:
  /// **'Laptops'**
  String get laptops;

  /// No description provided for @gaming.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get gaming;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @home_office.
  ///
  /// In en, this message translates to:
  /// **'Home & Office'**
  String get home_office;

  /// No description provided for @accessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get accessories;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @categories_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Categories will appear here when the catalog is available.'**
  String get categories_unavailable;

  /// No description provided for @no_brands_available.
  ///
  /// In en, this message translates to:
  /// **'No brands are available yet.'**
  String get no_brands_available;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @no_brand_products.
  ///
  /// In en, this message translates to:
  /// **'No {brand} products are available yet.'**
  String no_brand_products(String brand);

  /// No description provided for @your_cart.
  ///
  /// In en, this message translates to:
  /// **'Your Cart'**
  String get your_cart;

  /// No description provided for @cart_item_count.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String cart_item_count(String count);

  /// No description provided for @empty_cart_description.
  ///
  /// In en, this message translates to:
  /// **'Add a few things you love and they’ll show up here.'**
  String get empty_cart_description;

  /// No description provided for @browse_products.
  ///
  /// In en, this message translates to:
  /// **'Browse products'**
  String get browse_products;

  /// No description provided for @select_delivery_location.
  ///
  /// In en, this message translates to:
  /// **'Select delivery location'**
  String get select_delivery_location;

  /// No description provided for @map_pin_instruction.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to place the pin at your delivery address.'**
  String get map_pin_instruction;

  /// No description provided for @choose_map_point.
  ///
  /// In en, this message translates to:
  /// **'Choose a point on the map'**
  String get choose_map_point;

  /// No description provided for @favorites_refresh_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh favorites. Check your connection and try again.'**
  String get favorites_refresh_failed;

  /// No description provided for @favorites_empty_description.
  ///
  /// In en, this message translates to:
  /// **'Your favorite items will appear here.'**
  String get favorites_empty_description;

  /// No description provided for @view_product_details.
  ///
  /// In en, this message translates to:
  /// **'View product details'**
  String get view_product_details;

  /// No description provided for @edit_your_rating.
  ///
  /// In en, this message translates to:
  /// **'Edit your rating'**
  String get edit_your_rating;

  /// No description provided for @full_name.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get full_name;

  /// No description provided for @account_name.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get account_name;

  /// No description provided for @map_location_selected.
  ///
  /// In en, this message translates to:
  /// **'Map location selected · {coordinates}'**
  String map_location_selected(String coordinates);

  /// No description provided for @please_enter_field.
  ///
  /// In en, this message translates to:
  /// **'Please enter {field}.'**
  String please_enter_field(String field);

  /// No description provided for @pay_with_bank_transfer.
  ///
  /// In en, this message translates to:
  /// **'Pay with bank transfer'**
  String get pay_with_bank_transfer;

  /// No description provided for @pay_with_telebirr.
  ///
  /// In en, this message translates to:
  /// **'Pay with Telebirr'**
  String get pay_with_telebirr;

  /// No description provided for @pay_when_received.
  ///
  /// In en, this message translates to:
  /// **'Pay when you receive your order'**
  String get pay_when_received;

  /// No description provided for @upload_receipt_instruction.
  ///
  /// In en, this message translates to:
  /// **'Please upload your payment receipt or screenshot.'**
  String get upload_receipt_instruction;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get uploading;

  /// No description provided for @tap_to_upload.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload'**
  String get tap_to_upload;

  /// No description provided for @continue_to_review.
  ///
  /// In en, this message translates to:
  /// **'Continue to Review'**
  String get continue_to_review;

  /// No description provided for @continue_to_payment.
  ///
  /// In en, this message translates to:
  /// **'Continue to Payment'**
  String get continue_to_payment;

  /// No description provided for @continue_to_payment_proof.
  ///
  /// In en, this message translates to:
  /// **'Continue to Payment Proof'**
  String get continue_to_payment_proof;

  /// No description provided for @cbe_payment_instruction.
  ///
  /// In en, this message translates to:
  /// **'Please complete your payment using one of the methods below and upload the transaction proof:'**
  String get cbe_payment_instruction;

  /// No description provided for @open_payments_or_send_money.
  ///
  /// In en, this message translates to:
  /// **'2. Go to Payments or Send Money'**
  String get open_payments_or_send_money;

  /// No description provided for @scan_qr_or_merchant.
  ///
  /// In en, this message translates to:
  /// **'3. Scan the QR code or enter merchant details'**
  String get scan_qr_or_merchant;

  /// No description provided for @after_payment_upload.
  ///
  /// In en, this message translates to:
  /// **'After payment, upload the screenshot and select Confirm Payment.'**
  String get after_payment_upload;

  /// No description provided for @telebirr_payment_instruction.
  ///
  /// In en, this message translates to:
  /// **'Complete your payment using Telebirr and upload the transaction proof:'**
  String get telebirr_payment_instruction;

  /// No description provided for @send_money_or_payments.
  ///
  /// In en, this message translates to:
  /// **'2. Go to Send Money or Payments'**
  String get send_money_or_payments;

  /// No description provided for @no_proof_uploaded.
  ///
  /// In en, this message translates to:
  /// **'No proof uploaded yet'**
  String get no_proof_uploaded;

  /// No description provided for @open_payment_app.
  ///
  /// In en, this message translates to:
  /// **'1. Open {app}'**
  String open_payment_app(String app);

  /// No description provided for @amount_birr.
  ///
  /// In en, this message translates to:
  /// **'Amount: Birr {amount}'**
  String amount_birr(String amount);

  /// No description provided for @account_name_value.
  ///
  /// In en, this message translates to:
  /// **'Account Name: {value}'**
  String account_name_value(String value);

  /// No description provided for @account_number_value.
  ///
  /// In en, this message translates to:
  /// **'Account Number: {value}'**
  String account_number_value(String value);

  /// No description provided for @bank_value.
  ///
  /// In en, this message translates to:
  /// **'Bank: {value}'**
  String bank_value(String value);

  /// No description provided for @reference_value.
  ///
  /// In en, this message translates to:
  /// **'Reference: {value}'**
  String reference_value(String value);

  /// No description provided for @merchant_number_value.
  ///
  /// In en, this message translates to:
  /// **'3. Enter merchant number: {value}'**
  String merchant_number_value(String value);

  /// No description provided for @bank_transfer_or_cbe_birr.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer or CBE Birr'**
  String get bank_transfer_or_cbe_birr;

  /// No description provided for @mobile_money_payment.
  ///
  /// In en, this message translates to:
  /// **'Mobile money payment'**
  String get mobile_money_payment;

  /// No description provided for @order_placed_title.
  ///
  /// In en, this message translates to:
  /// **'Order Placed!'**
  String get order_placed_title;

  /// No description provided for @order_submitted_message.
  ///
  /// In en, this message translates to:
  /// **'Your order has been successfully submitted.'**
  String get order_submitted_message;

  /// No description provided for @view_order_details.
  ///
  /// In en, this message translates to:
  /// **'View Order Details'**
  String get view_order_details;

  /// No description provided for @continue_shopping_action.
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get continue_shopping_action;

  /// No description provided for @order_details_loading.
  ///
  /// In en, this message translates to:
  /// **'Order details are still loading. Try again from My Orders.'**
  String get order_details_loading;

  /// No description provided for @total_birr.
  ///
  /// In en, this message translates to:
  /// **'Total: Birr {amount}'**
  String total_birr(String amount);

  /// No description provided for @brand_tagline.
  ///
  /// In en, this message translates to:
  /// **'Better Phones. Brighter Days.'**
  String get brand_tagline;

  /// No description provided for @failed_update_cart.
  ///
  /// In en, this message translates to:
  /// **'Could not update the cart. Please try again.'**
  String get failed_update_cart;

  /// No description provided for @cart_cleared.
  ///
  /// In en, this message translates to:
  /// **'Cart cleared'**
  String get cart_cleared;

  /// No description provided for @payment_proof_selected.
  ///
  /// In en, this message translates to:
  /// **'Payment proof image selected'**
  String get payment_proof_selected;

  /// No description provided for @payment_proof_removed.
  ///
  /// In en, this message translates to:
  /// **'Payment proof removed'**
  String get payment_proof_removed;

  /// No description provided for @payment_proof_required.
  ///
  /// In en, this message translates to:
  /// **'Please select a payment proof image.'**
  String get payment_proof_required;

  /// No description provided for @upload_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not upload the payment proof. Please try again.'**
  String get upload_failed;

  /// No description provided for @login_required.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to place an order.'**
  String get login_required;

  /// No description provided for @order_create_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not create the order. Please try again.'**
  String get order_create_failed;

  /// No description provided for @address_fields_required.
  ///
  /// In en, this message translates to:
  /// **'Please fill all address fields.'**
  String get address_fields_required;

  /// No description provided for @welcome_user.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}!'**
  String welcome_user(String name);

  /// No description provided for @logged_out.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully.'**
  String get logged_out;

  /// No description provided for @profile_updated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully.'**
  String get profile_updated;

  /// No description provided for @password_changed.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get password_changed;

  /// No description provided for @password_updated_relogin.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully. Please sign in again.'**
  String get password_updated_relogin;

  /// No description provided for @rating_submitted.
  ///
  /// In en, this message translates to:
  /// **'Your rating was submitted.'**
  String get rating_submitted;

  /// No description provided for @rating_updated.
  ///
  /// In en, this message translates to:
  /// **'Your rating was updated.'**
  String get rating_updated;

  /// No description provided for @rating_deleted.
  ///
  /// In en, this message translates to:
  /// **'Your rating was deleted.'**
  String get rating_deleted;

  /// No description provided for @wrong_credentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong username or password. Please try again.'**
  String get wrong_credentials;

  /// No description provided for @email_already_registered.
  ///
  /// In en, this message translates to:
  /// **'This email already has an account. Sign in or use a different email.'**
  String get email_already_registered;

  /// No description provided for @verification_code_expired.
  ///
  /// In en, this message translates to:
  /// **'That code has expired. Request a new one and try again.'**
  String get verification_code_expired;

  /// No description provided for @too_many_code_attempts.
  ///
  /// In en, this message translates to:
  /// **'There were too many attempts. Wait a little, request a new code, and try again.'**
  String get too_many_code_attempts;

  /// No description provided for @resend_verification.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t send the code. Tap Resend code to try again. If it keeps failing, contact support.'**
  String get resend_verification;

  /// No description provided for @verification_code_mismatch.
  ///
  /// In en, this message translates to:
  /// **'That code does not match. Check the email and try again.'**
  String get verification_code_mismatch;

  /// No description provided for @wait_before_resend.
  ///
  /// In en, this message translates to:
  /// **'Please wait a minute before asking for another code.'**
  String get wait_before_resend;

  /// No description provided for @verification_email_unavailable.
  ///
  /// In en, this message translates to:
  /// **'We can’t send a verification email right now. Please try again later.'**
  String get verification_email_unavailable;

  /// No description provided for @too_many_incorrect_codes.
  ///
  /// In en, this message translates to:
  /// **'There were too many incorrect codes. Request a new one and try again.'**
  String get too_many_incorrect_codes;

  /// No description provided for @verify_email_first.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email address before creating your account.'**
  String get verify_email_first;

  /// No description provided for @server_error_retry.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side. Please try again in a moment.'**
  String get server_error_retry;

  /// No description provided for @username_taken.
  ///
  /// In en, this message translates to:
  /// **'This username is already taken. Please choose another one.'**
  String get username_taken;

  /// No description provided for @connection_error.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to the server. Check your internet connection.'**
  String get connection_error;

  /// No description provided for @request_timeout.
  ///
  /// In en, this message translates to:
  /// **'The request timed out. Please try again.'**
  String get request_timeout;

  /// No description provided for @server_not_responding.
  ///
  /// In en, this message translates to:
  /// **'The server is not responding. Please try again later.'**
  String get server_not_responding;

  /// No description provided for @both_credentials_required.
  ///
  /// In en, this message translates to:
  /// **'Enter both your username and password.'**
  String get both_credentials_required;

  /// No description provided for @password_required.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get password_required;

  /// No description provided for @general_retry.
  ///
  /// In en, this message translates to:
  /// **'We could not complete that. Please try again.'**
  String get general_retry;

  /// No description provided for @current_password_incorrect.
  ///
  /// In en, this message translates to:
  /// **'Your current password is incorrect. Please try again.'**
  String get current_password_incorrect;

  /// No description provided for @enter_current_password.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password to make changes.'**
  String get enter_current_password;

  /// No description provided for @username_cannot_empty.
  ///
  /// In en, this message translates to:
  /// **'Username cannot be empty.'**
  String get username_cannot_empty;

  /// No description provided for @choose_different_username.
  ///
  /// In en, this message translates to:
  /// **'This username is already taken. Please choose a different one.'**
  String get choose_different_username;

  /// No description provided for @profile_picture_updated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated successfully.'**
  String get profile_picture_updated;

  /// No description provided for @profile_image_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not update the profile picture. Please try again.'**
  String get profile_image_failed;

  /// No description provided for @delivery_addresses.
  ///
  /// In en, this message translates to:
  /// **'Saved Destinations'**
  String get delivery_addresses;

  /// No description provided for @default_label.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get default_label;

  /// No description provided for @add_new_address.
  ///
  /// In en, this message translates to:
  /// **'Add New Address'**
  String get add_new_address;

  /// No description provided for @address_name.
  ///
  /// In en, this message translates to:
  /// **'Address name'**
  String get address_name;

  /// No description provided for @home_address.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home_address;

  /// No description provided for @office_address.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get office_address;

  /// No description provided for @save_address.
  ///
  /// In en, this message translates to:
  /// **'Save Address'**
  String get save_address;

  /// No description provided for @edit_address.
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get edit_address;

  /// No description provided for @saved_addresses_empty.
  ///
  /// In en, this message translates to:
  /// **'Add an address so it’s ready at checkout.'**
  String get saved_addresses_empty;

  /// No description provided for @map_address.
  ///
  /// In en, this message translates to:
  /// **'Choose on map'**
  String get map_address;

  /// No description provided for @remove_address.
  ///
  /// In en, this message translates to:
  /// **'Remove address'**
  String get remove_address;

  /// No description provided for @address_saved.
  ///
  /// In en, this message translates to:
  /// **'Address saved.'**
  String get address_saved;

  /// No description provided for @language_changed.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}.'**
  String language_changed(String language);

  /// No description provided for @support_contact_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Support contact details are not available yet.'**
  String get support_contact_unavailable;

  /// No description provided for @destination_information.
  ///
  /// In en, this message translates to:
  /// **'Destination Information'**
  String get destination_information;

  /// No description provided for @destination_city.
  ///
  /// In en, this message translates to:
  /// **'Destination city'**
  String get destination_city;

  /// No description provided for @area_landmark_optional.
  ///
  /// In en, this message translates to:
  /// **'Area or landmark (optional)'**
  String get area_landmark_optional;

  /// No description provided for @collection_explanation.
  ///
  /// In en, this message translates to:
  /// **'Your destination helps coordinate transport. YoMart staff will agree a collection point with you.'**
  String get collection_explanation;

  /// No description provided for @collection_point.
  ///
  /// In en, this message translates to:
  /// **'Agreed collection point'**
  String get collection_point;

  /// No description provided for @collection_point_not_agreed.
  ///
  /// In en, this message translates to:
  /// **'The collection point has not been agreed yet.'**
  String get collection_point_not_agreed;

  /// No description provided for @ready_for_collection.
  ///
  /// In en, this message translates to:
  /// **'Ready for Collection'**
  String get ready_for_collection;

  /// No description provided for @collected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get collected;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['am', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
