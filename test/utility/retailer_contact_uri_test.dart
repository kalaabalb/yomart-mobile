import 'package:e_commerce_flutter/models/retailer_contact.dart';
import 'package:e_commerce_flutter/utility/retailer_contact_uri.dart';
import 'package:flutter_test/flutter_test.dart';

RetailerContact contact(String type, String value,
        {String placement = 'all'}) =>
    RetailerContact(
      label: 'Configured label',
      description: '',
      type: type,
      value: value,
      placement: placement,
      displayOrder: 0,
    );

void main() {
  test('builds native actions only for validated configured contact values',
      () {
    expect(retailerContactUri(contact('phone', '+251 911 222 333')).toString(),
        'tel:+251911222333');
    expect(
        retailerContactUri(contact('telegram', '@sample_contact')).toString(),
        'https://t.me/sample_contact');
    expect(
        retailerContactUri(contact('whatsapp', '+251 911 222 333')).toString(),
        'https://wa.me/251911222333');
    expect(retailerContactUri(contact('email', 'help@example.org')).toString(),
        'mailto:help@example.org');
    expect(
        retailerContactUri(contact('website', 'https://example.org/support'))
            .toString(),
        'https://example.org/support');
  });

  test('unsafe values and unsupported schemes fail closed', () {
    expect(
        retailerContactUri(contact('telegram', 'https://t.me/not-a-username')),
        isNull);
    expect(
        retailerContactUri(
          contact('website', 'javascript:alert(1)'),
        ),
        isNull);
    expect(
        retailerContactUri(contact('other', 'https://user:pass@example.org')),
        isNull);
    expect(retailerContactUri(contact('other', 'mailto:test@example.org')),
        isNull);
  });

  test('placement supports shared and specific customer destinations', () {
    expect(
        contact('phone', '123456789', placement: 'all')
            .appearsAt('support_page'),
        isTrue);
    expect(
        contact('phone', '123456789', placement: 'product_details')
            .appearsAt('support_page'),
        isFalse);
  });
}
