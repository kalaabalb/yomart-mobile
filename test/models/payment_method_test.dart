import 'package:e_commerce_flutter/models/order.dart';
import 'package:e_commerce_flutter/models/store_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses arbitrary payment method fields and proof requirements', () {
    final method = StorePaymentMethod.fromJson({
      'code': 'provider-created-method',
      'name': 'Configurable provider',
      'description': 'Configured by the store owner',
      'category': 'mobile_wallet',
      'enabled': true,
      'requiresProof': false,
      'providerName': 'Any provider',
      'accountHolder': 'Synthetic Recipient',
      'accountIdentifier': 'synthetic-id',
      'additionalDetails': 'Additional details',
      'instructions': 'Instructions',
    });

    expect(method.code, 'provider-created-method');
    expect(method.title, 'Configurable provider');
    expect(method.category, 'mobile_wallet');
    expect(method.requiresProof, isFalse);
    expect(method.accountIdentifier, 'synthetic-id');
  });

  test('legacy method records retain their previous proof behavior', () {
    expect(StorePaymentMethod.fromJson({'code': 'cod', 'title': 'Cash'}).requiresProof, isFalse);
    expect(StorePaymentMethod.fromJson({'code': 'cbe', 'title': 'Bank'}).requiresProof, isTrue);
  });

  test('order details read saved payment method snapshot and legacy orders remain valid', () {
    final order = Order.fromJson({
      '_id': 'synthetic-order',
      'paymentMethod': 'mutable-id',
      'paymentMethodSnapshot': {
        'code': 'mutable-id',
        'name': 'Saved original method',
        'category': 'other',
        'requiresProof': false,
        'instructions': 'Saved instructions',
      },
    });
    expect(order.paymentMethodSnapshot?.name, 'Saved original method');
    expect(order.paymentMethodSnapshot?.instructions, 'Saved instructions');
    expect(Order.fromJson({'paymentMethod': 'cod'}).paymentMethodSnapshot, isNull);
  });
}
