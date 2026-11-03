import 'dart:io';

import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:e_commerce_flutter/main.dart';
import 'package:e_commerce_flutter/screen/login_screen/provider/user_provider.dart';
import 'package:e_commerce_flutter/screen/profile_screen/provider/profile_provider.dart';
import 'package:e_commerce_flutter/screen/product_by_category_screen/provider/product_by_category_provider.dart';
import 'package:e_commerce_flutter/screen/product_cart_screen/provider/cart_provider.dart';
import 'package:e_commerce_flutter/screen/product_details_screen/provider/product_detail_provider.dart';
import 'package:e_commerce_flutter/screen/product_details_screen/provider/rating_provider.dart';
import 'package:e_commerce_flutter/screen/product_favorite_screen/provider/favorite_provider.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/provider/product_list_provider.dart';
import 'package:e_commerce_flutter/screen/splash_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:e_commerce_flutter/l10n/app_localizations.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    const pathProviderChannel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        final storageDir = await Directory.systemTemp.createTemp(
          'get_storage',
        );
        return storageDir.path;
      }
      return null;
    });

    await GetStorage.init();
  });

  testWidgets('app displays the splash screen during startup',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DataProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(create: (_) => ProductListProvider()),
          ChangeNotifierProvider(create: (_) => ProductByCategoryProvider()),
          ChangeNotifierProvider(create: (_) => ProductDetailProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => FavoriteProvider()),
          ChangeNotifierProvider(create: (_) => RatingProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Let DataProvider's bounded startup retry delays finish in fake time.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsOneWidget);
  });

  testWidgets('changing language updates visible localized text',
      (WidgetTester tester) async {
    final data = DataProvider();
    data.changeLanguage('en');
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: data,
        child: Consumer<DataProvider>(
          builder: (context, provider, _) => MaterialApp(
            locale: Locale(provider.currentLanguage),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            home: Builder(
              builder: (context) => Scaffold(
                body: Text(AppLocalizations.of(context).home),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    data.changeLanguage('es');
    await tester.pumpAndSettle();
    expect(find.text('Inicio'), findsOneWidget);
    expect(GetStorage().read('language'), 'es');
    // Finish DataProvider's bounded startup retries to avoid leaving its
    // deliberate two-second retry timers pending in fake time.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
