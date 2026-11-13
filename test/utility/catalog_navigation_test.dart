import 'package:e_commerce_flutter/models/brand.dart';
import 'package:e_commerce_flutter/models/category.dart';
import 'package:e_commerce_flutter/models/product.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/components/category_selector.dart';
import 'package:e_commerce_flutter/screen/product_list_screen/provider/product_list_provider.dart';
import 'package:e_commerce_flutter/screen/product_by_category_screen/product_by_category_screen.dart';
import 'package:e_commerce_flutter/screen/product_by_category_screen/provider/product_by_category_provider.dart';
import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce_flutter/utility/catalog_navigation.dart';
import 'package:e_commerce_flutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('poster navigation clears marketing text instead of searching it', () {
    final provider = ProductListProvider();
    final products = [Product(sId: 'product-1', name: 'Galaxy phone')];
    provider.searchProducts('Samsung Galaxy collection', products);
    var revealed = false;

    browseCatalogFromPoster(
      productList: provider,
      products: products,
      revealProducts: () => revealed = true,
    );

    expect(provider.searchQuery, isEmpty);
    expect(provider.filteredProducts, products);
    expect(revealed, isTrue);
  });

  testWidgets(
      'Samsung brand shortcut opens the shared category catalog controls',
      (tester) async {
    final brand = Brand(name: 'Samsung');
    final products = [
      Product(
        sId: 'samsung-1',
        name: 'Phone',
        proBrandId: ProRef(name: 'Samsung'),
      ),
    ];
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => DataProvider(loadInitialData: false)),
          ChangeNotifierProvider(create: (_) => ProductByCategoryProvider()),
        ],
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) => Scaffold(
              body: CategorySelector(
                categories: [Category(name: 'Phones')],
                brands: [brand],
                onSamsungTap: () => openBrandProducts(context,
                    brand: brand, products: products),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Samsung'));
    await tester.pumpAndSettle();
    expect(find.byType(ProductByCategoryScreen), findsOneWidget);
    expect(find.text('Sort By Price'), findsOneWidget);
    expect(find.text('Brands'), findsOneWidget);
  });
}
