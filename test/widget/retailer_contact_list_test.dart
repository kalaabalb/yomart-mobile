import 'package:e_commerce_flutter/models/retailer_contact.dart';
import 'package:e_commerce_flutter/widget/retailer_contact_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host({
    List<RetailerContact> contacts = const [],
    bool loading = false,
    String? error,
  }) =>
      MaterialApp(
        home: Scaffold(
          body: RetailerContactList(
            contacts: contacts,
            placement: 'support_page',
            loading: loading,
            error: error,
            onRetry: () {},
            onSelected: (_) {},
            emptyMessage: 'No contact options configured.',
          ),
        ),
      );

  testWidgets(
      'renders a matching configured contact and hides other placements',
      (tester) async {
    await tester.pumpWidget(host(contacts: const [
      RetailerContact(
          label: 'Configured phone',
          description: 'Call support',
          type: 'phone',
          value: '+123456789',
          placement: 'support_page',
          displayOrder: 0),
      RetailerContact(
          label: 'Product only',
          description: '',
          type: 'email',
          value: 'help@example.org',
          placement: 'product_details',
          displayOrder: 1),
    ]));

    expect(find.text('Configured phone'), findsOneWidget);
    expect(find.text('Call support'), findsOneWidget);
    expect(find.text('Product only'), findsNothing);
  });

  testWidgets(
      'renders loading, empty, and error states without contact fallbacks',
      (tester) async {
    await tester.pumpWidget(host(loading: true));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpWidget(host());
    expect(find.text('No contact options configured.'), findsOneWidget);

    await tester.pumpWidget(host(error: 'temporary failure'));
    expect(find.text('Contact options unavailable · Retry'), findsOneWidget);
  });
}
