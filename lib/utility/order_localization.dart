import '../l10n/app_localizations.dart';

String localizeOrderStatus(AppLocalizations strings, String? value) =>
    switch (value?.toLowerCase()) {
      'payment_pending' => strings.awaiting_payment,
      'payment_verified' => strings.payment_verified,
      'processing' => strings.order_processing,
      'shipped' => strings.order_shipped,
      'ready_for_collection' => strings.ready_for_collection,
      'collected' => strings.collected,
      'delivered' => strings.order_delivered,
      'cancelled' => strings.order_cancelled,
      _ => strings.order_pending,
    };

List<String> orderTrackingLabels(AppLocalizations strings, String? status) =>
    status?.toLowerCase() == 'delivered'
        ? [
            strings.order_processing,
            strings.order_shipped,
            strings.order_delivered
          ]
        : [
            strings.order_processing,
            strings.order_shipped,
            strings.ready_for_collection,
            strings.collected,
          ];

int orderTrackingActiveIndex(String? value) => switch (value?.toLowerCase()) {
      'collected' => 3,
      'ready_for_collection' => 2,
      'delivered' => 2,
      'shipped' => 1,
      'processing' || 'payment_verified' => 0,
      _ => -1,
    };

String localizePaymentStatus(AppLocalizations strings, String? value) =>
    switch (value?.toLowerCase()) {
      'verified' => strings.payment_verified,
      'failed' => strings.payment_failed_status,
      _ => strings.payment_pending,
    };
