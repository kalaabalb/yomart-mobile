class StorePaymentMethod {
  const StorePaymentMethod({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.instructions,
    required this.category,
    required this.requiresProof,
    required this.logoUrl,
    required this.providerName,
    required this.accountHolder,
    required this.accountIdentifier,
    required this.additionalDetails,
  });

  final String code;
  final String title;
  final String subtitle;
  final bool enabled;
  final String instructions;
  final String category;
  final bool requiresProof;
  final String logoUrl;
  final String providerName;
  final String accountHolder;
  final String accountIdentifier;
  final String additionalDetails;

  bool get isCashCollection => category == 'cash_collection';

  factory StorePaymentMethod.fromJson(Map<String, dynamic> json) {
    final code = json['code']?.toString() ?? '';
    final category = json['category']?.toString() ?? switch (code) {
      'cod' => 'cash_collection',
      'cbe' => 'bank_transfer',
      'telebirr' => 'mobile_wallet',
      _ => 'other',
    };
    return StorePaymentMethod(
      code: code,
      title: json['name']?.toString() ?? json['title']?.toString() ?? '',
      subtitle: json['description']?.toString() ?? json['subtitle']?.toString() ?? '',
      enabled: json['enabled'] == true,
      instructions: json['instructions']?.toString() ?? '',
      category: category,
      requiresProof: json['requiresProof'] is bool
          ? json['requiresProof'] as bool
          : code != 'cod',
      logoUrl: json['logoUrl']?.toString() ?? '',
      providerName: json['providerName']?.toString() ?? '',
      accountHolder: json['accountHolder']?.toString() ?? '',
      accountIdentifier: json['accountIdentifier']?.toString() ?? '',
      additionalDetails: json['additionalDetails']?.toString() ?? '',
    );
  }
}

class StoreSettings {
  const StoreSettings({
    required this.supportPhone,
    required this.supportTelegram,
    required this.supportInstagram,
    required this.deliveryFee,
    required this.paymentMethods,
  });

  final String supportPhone;
  final String supportTelegram;
  final String supportInstagram;
  final double deliveryFee;
  final List<StorePaymentMethod> paymentMethods;

  static const defaults = StoreSettings(
    supportPhone: '',
    supportTelegram: '',
    supportInstagram: '',
    deliveryFee: 0,
    // Payment options must come from the admin-managed store settings API.
    paymentMethods: [],
  );

  factory StoreSettings.fromJson(Map<String, dynamic> json) {
    final methods = json['paymentMethods'];
    return StoreSettings(
      supportPhone: json['supportPhone']?.toString() ?? '',
      supportTelegram: json['supportTelegram']?.toString() ?? '',
      supportInstagram: json['supportInstagram']?.toString() ?? '',
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
      paymentMethods: methods is List
          ? methods
              .whereType<Map>()
              .map((method) => StorePaymentMethod.fromJson(
                    Map<String, dynamic>.from(method),
                  ))
              .toList()
          : const [],
    );
  }
}
