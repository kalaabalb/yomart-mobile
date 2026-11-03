import 'package:flutter_test/flutter_test.dart';
import 'package:e_commerce_flutter/core/utility/order_attempt.dart';

void main() {
  test('order attempt reuses a key for the same checkout and rotates it for changed contents', () {
    final request = <String, dynamic>{
      'items': [<String, dynamic>{'productID': 'synthetic-product', 'quantity': 2}],
      'shippingAddress': <String, dynamic>{'phone': '5550000', 'street': 'Test street', 'city': 'Test city'},
      'paymentMethod': 'cod',
    };
    final key = retainOrderIdempotencyKey(
      request: request,
      previousFingerprint: null,
      previousKey: null,
    );
    expect(key, matches(RegExp(r'^[0-9a-f-]{36}$')));
    expect(
      retainOrderIdempotencyKey(
        request: request,
        previousFingerprint: orderRequestFingerprint(request),
        previousKey: key,
      ),
      key,
    );
    final changed = {...request, 'paymentMethod': 'cbe'};
    expect(
      retainOrderIdempotencyKey(
        request: changed,
        previousFingerprint: orderRequestFingerprint(request),
        previousKey: key,
      ),
      isNot(key),
    );
  });
}
