Map<String, Uri> storeContactLinks({
  required String phone,
  required String telegram,
  required String instagram,
}) {
  final links = <String, Uri>{};
  final normalizedPhone = phone.trim();
  if (RegExp(r'^\+?[0-9().\-\s]{5,40}$').hasMatch(normalizedPhone) &&
      normalizedPhone.replaceAll(RegExp(r'\D'), '').length >= 5) {
    links['phone'] = Uri(scheme: 'tel', path: normalizedPhone);
  }

  final telegramUsername = telegram.trim().replaceFirst(RegExp(r'^@'), '');
  if (RegExp(r'^[A-Za-z0-9_]{5,32}$').hasMatch(telegramUsername)) {
    links['telegram'] = Uri.https('t.me', '/$telegramUsername');
  }

  final instagramUsername = instagram.trim().replaceFirst(RegExp(r'^@'), '');
  if (RegExp(r'^[A-Za-z0-9._]{1,30}$').hasMatch(instagramUsername)) {
    links['instagram'] = Uri.https('www.instagram.com', '/$instagramUsername/');
  }
  return links;
}

String contactLabel(String key) => switch (key) {
      'phone' => 'Call',
      'telegram' => 'Telegram',
      'instagram' => 'Instagram',
      _ => 'Contact',
    };
