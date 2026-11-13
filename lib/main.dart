import 'dart:async';

import 'package:e_commerce_flutter/screen/splash_screen.dart';
import 'package:e_commerce_flutter/screen/home_screen.dart';
import 'package:e_commerce_flutter/screen/login_screen/login_screen.dart';
import 'package:e_commerce_flutter/utility/text_direction_fix.dart';
import 'screen/product_details_screen/provider/rating_provider.dart';
import 'screen/login_screen/provider/user_provider.dart';
import 'screen/product_by_category_screen/provider/product_by_category_provider.dart';
import 'screen/product_cart_screen/provider/cart_provider.dart';
import 'screen/product_details_screen/provider/product_detail_provider.dart';
import 'screen/product_favorite_screen/provider/favorite_provider.dart';
import 'screen/product_list_screen/provider/product_list_provider.dart';
import 'screen/profile_screen/provider/profile_provider.dart';
import 'utility/app_theme.dart';
import 'utility/constants.dart';
import 'utility/release_origin_policy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_cart/cart.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:provider/provider.dart';
import 'core/data/data_provider.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BootstrapApp());
}

class BootstrapApp extends StatefulWidget {
  const BootstrapApp({super.key});

  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp> {
  UserProvider? _userProvider;
  Object? _startupError;

  @override
  void initState() {
    super.initState();
    unawaited(_initializeApp());
  }

  Future<void> _initializeApp() async {
    try {
      if (mainUrl.isEmpty) {
        throw StateError(
          'This release has no API URL. Rebuild it with the required YoMart API configuration.',
        );
      }
      final apiUri = Uri.tryParse(mainUrl);
      final localHost = apiUri != null && _isLocalHost(apiUri.host);
      if (kReleaseMode) {
        _validateReleaseApiTarget(apiUri);
      }
      if (kReleaseMode &&
          (apiUri == null ||
              !apiUri.hasAuthority ||
              (apiUri.scheme != 'https' &&
                  !(localHost && _allowInsecureLocalApi)))) {
        throw StateError(
          'Release builds require an HTTPS API URL. Local HTTP testing requires --dart-define=ALLOW_INSECURE_LOCAL_API=true.',
        );
      }
      final policyUri = Uri.tryParse(privacyPolicyUrl);
      final localPolicyHost = policyUri != null && _isLocalHost(policyUri.host);
      if (kReleaseMode &&
          (policyUri == null ||
              !policyUri.hasAuthority ||
              policyUri.userInfo.isNotEmpty ||
              policyUri.query.isNotEmpty ||
              policyUri.fragment.isNotEmpty ||
              _isPlaceholderApiHost(policyUri.host) ||
              (policyUri.scheme != 'https' &&
                  !(localPolicyHost && _allowInsecureLocalApi)))) {
        throw StateError(
          'Release builds require an HTTPS privacy policy URL. '
          'Rebuild with the required YoMart privacy-policy configuration.',
        );
      }
      if (kReleaseMode) _validateReleaseSiteTarget(policyUri);
      await GetStorage.init();
      final cart = FlutterCart();
      await cart.initializeCart(isPersistenceSupportEnabled: true);
      final userProvider = UserProvider();
      if (!mounted) return;
      setState(() => _userProvider = userProvider);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final user = userProvider.getLoginUsr();
        Get.offAll(
          user?.sId != null ? const HomeScreen() : const LoginScreen(),
        );
        unawaited(userProvider.restoreSession());
        unawaited(_configureNotifications());
      });
    } catch (error, stackTrace) {
      debugPrint('App startup could not initialize local data: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        setState(() => _startupError = error);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Get.offAll(const _StartupErrorScreen());
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = _userProvider;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DataProvider()),
        if (userProvider != null) ...[
          ChangeNotifierProvider.value(value: userProvider),
          ChangeNotifierProvider(create: (context) => ProfileProvider()),
          ChangeNotifierProvider(create: (context) => ProductListProvider()),
          ChangeNotifierProvider(
            create: (context) => ProductByCategoryProvider(),
          ),
          ChangeNotifierProvider(create: (context) => ProductDetailProvider()),
          ChangeNotifierProvider(create: (context) => CartProvider()),
          ChangeNotifierProvider(create: (context) => FavoriteProvider()),
          ChangeNotifierProvider(create: (context) => RatingProvider()),
        ],
      ],
      child: MyApp(startupError: _startupError),
    );
  }
}

const _oneSignalAppId = String.fromEnvironment('ONE_SIGNAL_APP_ID');
const _allowInsecureLocalApi = bool.fromEnvironment('ALLOW_INSECURE_LOCAL_API');
const _buildEnvironment = String.fromEnvironment('YOMART_BUILD_ENV');
const _expectedApiOrigin = String.fromEnvironment('YOMART_EXPECTED_API_ORIGIN');
const _productionApiOrigins =
    String.fromEnvironment('YOMART_PRODUCTION_API_ORIGINS');
const _stagingApiOrigins = String.fromEnvironment('YOMART_STAGING_API_ORIGINS');
const _productionSiteOrigins =
    String.fromEnvironment('YOMART_PRODUCTION_SITE_ORIGINS');
const _stagingSiteOrigins =
    String.fromEnvironment('YOMART_STAGING_SITE_ORIGINS');
const _noStagingApi = bool.fromEnvironment('YOMART_NO_STAGING_API');
const _noStagingSite = bool.fromEnvironment('YOMART_NO_STAGING_SITE');
const _notificationPromptedKey = 'notification_permission_prompted';
const _notificationGrantedKey = 'notification_permission_granted';

void _validateReleaseApiTarget(Uri? apiUri) {
  if (apiUri == null ||
      !apiUri.hasAuthority ||
      (apiUri.path.isNotEmpty && apiUri.path != '/') ||
      apiUri.query.isNotEmpty ||
      apiUri.fragment.isNotEmpty ||
      apiUri.userInfo.isNotEmpty ||
      !const {'local', 'staging', 'production'}.contains(_buildEnvironment)) {
    throw StateError(
        'Release build is missing its YoMart environment/API configuration.');
  }

  final expectedUri = Uri.tryParse(_expectedApiOrigin);
  if (expectedUri == null ||
      !expectedUri.hasAuthority ||
      apiUri.origin != expectedUri.origin ||
      (expectedUri.path.isNotEmpty && expectedUri.path != '/') ||
      expectedUri.query.isNotEmpty ||
      expectedUri.fragment.isNotEmpty ||
      expectedUri.userInfo.isNotEmpty ||
      _isPlaceholderApiHost(apiUri.host)) {
    throw StateError(
        'Release API URL does not match its configured expected origin.');
  }

  final localHost = _isLocalHost(apiUri.host);
  if (_buildEnvironment == 'local') {
    if (!localHost) {
      throw StateError('A local release build must use a loopback API.');
    }
    return;
  }
  if (localHost || apiUri.scheme != 'https') {
    throw StateError(
        'Staging and production releases require a non-local HTTPS API.');
  }

  final blockedOrigins = <String>{};
  if (_buildEnvironment == 'production' && _noStagingApi) {
    if (_stagingApiOrigins.trim().isNotEmpty) {
      throw StateError(
          'YOMART_NO_STAGING_API=true cannot be combined with staging API origins.');
    }
    // The former staging API was converted to the production service. Keep
    // known retired API hosts blocked even when no separate staging service exists.
    blockedOrigins.addAll(const {
      'https://yonasmarketplace-backend.onrender.com',
      'https://ecommerce-backend-api-jet.vercel.app',
    });
  } else {
    if (_noStagingApi) {
      throw StateError(
          'YOMART_NO_STAGING_API is valid only for a production build.');
    }
    const isStaging = _buildEnvironment == 'staging';
    blockedOrigins.addAll(validateReleaseOriginDenylist(
      isStaging ? _productionApiOrigins : _stagingApiOrigins,
      name: isStaging
          ? 'YOMART_PRODUCTION_API_ORIGINS'
          : 'YOMART_STAGING_API_ORIGINS',
      allowEmpty: isStaging,
    ));
    if (isStaging) {
      // Keep retired production API hosts blocked even when the current
      // production API origin is not yet separately configured.
      blockedOrigins.addAll(const {
        'https://yonasmarketplace-backend.onrender.com',
        'https://ecommerce-backend-api-jet.vercel.app',
      });
    }
  }
  if (blockedOrigins.contains(apiUri.origin)) {
    throw StateError('Release API origin belongs to the opposite environment.');
  }
}

void _validateReleaseSiteTarget(Uri? policyUri) {
  if (_buildEnvironment == 'local') return;
  if (policyUri == null || !policyUri.hasAuthority) {
    throw StateError('Release build is missing its YoMart site configuration.');
  }
  final siteOrigin = policyUri.origin;
  if (kIsWeb && Uri.base.origin != siteOrigin) {
    throw StateError(
        'The hosted YoMart web origin does not match its compiled storefront origin.');
  }
  if (_buildEnvironment == 'production' && _noStagingSite) {
    if (_stagingSiteOrigins.trim().isNotEmpty) {
      throw StateError(
          'YOMART_NO_STAGING_SITE=true cannot be combined with staging site origins.');
    }
    return;
  }
  if (_noStagingSite) {
    throw StateError(
        'YOMART_NO_STAGING_SITE is valid only for a production build.');
  }
  const isStaging = _buildEnvironment == 'staging';
  final blockedOrigins = validateReleaseOriginDenylist(
    isStaging ? _productionSiteOrigins : _stagingSiteOrigins,
    name: isStaging
        ? 'YOMART_PRODUCTION_SITE_ORIGINS'
        : 'YOMART_STAGING_SITE_ORIGINS',
    allowEmpty: isStaging,
  );
  if (blockedOrigins.contains(siteOrigin)) {
    throw StateError(
        'Release site origin belongs to the opposite environment.');
  }
}

bool _isPlaceholderApiHost(String host) {
  final normalized = host.toLowerCase();
  return normalized.contains('replace-with') ||
      normalized.contains('placeholder') ||
      normalized.contains('your-api-domain') ||
      normalized == 'example' ||
      normalized.endsWith('.example') ||
      const {'example.com', 'example.org', 'example.net', 'example.invalid'}
          .contains(normalized);
}

bool _isLocalHost(String host) =>
    const {'localhost', '::1', '[::1]'}.contains(host) ||
    host.endsWith('.localhost') ||
    RegExp(r'^127(?:\.\d{1,3}){3}$').hasMatch(host);

Future<void> _configureNotifications() async {
  // An app ID from the OneSignal dashboard is required for real push delivery.
  // Avoid initializing the SDK with a placeholder or showing a permission prompt
  // that cannot be associated with this app's notification service.
  if (_oneSignalAppId.isEmpty) return;

  try {
    OneSignal.initialize(_oneSignalAppId);

    final storage = GetStorage();
    if (storage.read<bool>(_notificationPromptedKey) == true) return;

    if (await OneSignal.Notifications.canRequest()) {
      final granted = await OneSignal.Notifications.requestPermission(true);
      await storage.write(_notificationGrantedKey, granted);
      await storage.write(_notificationPromptedKey, true);
    } else {
      await storage.write(
        _notificationGrantedKey,
        OneSignal.Notifications.permission,
      );
    }
  } catch (error) {
    debugPrint('Could not initialize push notifications: $error');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.startupError});

  final Object? startupError;

  @override
  Widget build(BuildContext context) {
    return LTRTextDirection(
      child: GetMaterialApp(
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
        ),
        debugShowCheckedModeBanner: false,
        home: startupError != null
            ? const _StartupErrorScreen()
            : const SplashScreen(holdAtSplash: true),
        theme: AppTheme.lightAppTheme,
        darkTheme: AppTheme.darkAppTheme,
        themeMode: context.watch<DataProvider>().isDarkMode
            ? ThemeMode.dark
            : ThemeMode.light,
        locale: Locale(context.watch<DataProvider>().currentLanguage),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        fallbackLocale: const Locale('en'),
        // Override MaterialApp's internally animated Theme in one place. This
        // applies the selected palette to the full navigator subtree at once,
        // instead of letting individual widgets visibly drift between themes.
        builder: (context, child) => Theme(
          key: const ValueKey('yomart-app-theme'),
          data: context.watch<DataProvider>().isDarkMode
              ? AppTheme.darkAppTheme
              : AppTheme.lightAppTheme,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  const _StartupErrorScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF000000),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Text(
            'YoMart could not finish starting. Please close and reopen the app.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
          ),
        ),
      ),
    );
  }
}
