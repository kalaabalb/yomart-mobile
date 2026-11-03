import 'package:e_commerce_flutter/l10n/app_localizations_en.dart';
import 'package:e_commerce_flutter/models/order.dart';
import 'package:e_commerce_flutter/utility/order_localization.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final strings = AppLocalizationsEn();

  test('collection statuses have customer-facing labels and tracking stages',
      () {
    expect(localizeOrderStatus(strings, 'ready_for_collection'),
        'Ready for Collection');
    expect(localizeOrderStatus(strings, 'collected'), 'Collected');
    expect(orderTrackingLabels(strings, 'ready_for_collection'), [
      'Processing',
      'Shipped',
      'Ready for Collection',
      'Collected',
    ]);
    expect(orderTrackingActiveIndex('ready_for_collection'), 2);
    expect(orderTrackingActiveIndex('collected'), 3);
  });

  test('historical delivered orders retain their delivery status timeline', () {
    expect(localizeOrderStatus(strings, 'delivered'), 'Delivered');
    expect(orderTrackingLabels(strings, 'delivered'),
        ['Processing', 'Shipped', 'Delivered']);
    expect(orderTrackingActiveIndex('delivered'), 2);
  });

  test(
      'orders parse optional collection point without changing destination address',
      () {
    final order = Order.fromJson({
      '_id': 'synthetic-order',
      'orderStatus': 'ready_for_collection',
      'shippingAddress': {
        'phone': '5550000',
        'city': 'Bahir Dar',
        'street': 'Area 1'
      },
      'collectionPoint': {
        'name': 'Agreed site',
        'address': 'Staff address',
        'city': 'Bahir Dar'
      },
    });
    expect(order.shippingAddress?.street, 'Area 1');
    expect(order.collectionPoint?.formattedAddress, 'Staff address, Bahir Dar');
    expect(order.toJson()['collectionPoint']['name'], 'Agreed site');
  });
}
