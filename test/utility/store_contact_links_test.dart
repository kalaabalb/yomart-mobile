import 'package:e_commerce_flutter/utility/store_contact_links.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds the configured phone, Telegram, and Instagram actions', () {
    final links = storeContactLinks(
      phone: '+251 911 222 333',
      telegram: '@yomart_store',
      instagram: '@yomart.shop',
    );

    expect(links['phone'].toString(), 'tel:+251%20911%20222%20333');
    expect(links['telegram'].toString(), 'https://t.me/yomart_store');
    expect(links['instagram'].toString(),
        'https://www.instagram.com/yomart.shop/');
    expect(contactLabel('phone'), 'Call');
    expect(contactLabel('telegram'), 'Telegram');
    expect(contactLabel('instagram'), 'Instagram');
  });

  test('omits unset or unsafe contact values', () {
    final links = storeContactLinks(
      phone: 'javascript:alert(1)',
      telegram: 'https://t.me/yomart',
      instagram: 'https://instagram.com/yomart',
    );
    expect(links, isEmpty);
  });
}
