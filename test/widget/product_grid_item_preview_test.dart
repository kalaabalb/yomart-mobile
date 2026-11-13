import 'package:e_commerce_flutter/models/product.dart';
import 'package:e_commerce_flutter/shared/widgets/product_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('compact preview product card fits and hides price and stock',
      (tester) async {
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 164,
              height: 222,
              child: ProductGridItem(
                product: Product(
                  sId: 'preview-test',
                  name: 'A long sample phone name that wraps on compact cards',
                  price: 125000,
                  quantity: 3,
                ),
                onTap: () {},
                onFavoriteTap: () {},
                isFavorite: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Birr'), findsNothing);
    expect(find.textContaining('Stock'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
