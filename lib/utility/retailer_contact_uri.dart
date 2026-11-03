import 'package:e_commerce_flutter/models/retailer_contact.dart';

Uri? retailerContactUri(RetailerContact contact) {
  final value = contact.value.trim();
  switch (contact.type) {
    case 'phone':
      if (!RegExp(r'^\+?[0-9().\-\s]{5,40}$').hasMatch(value) ||
          value.replaceAll(RegExp(r'\D'), '').length < 5) {
        return null;
      }
      return Uri(scheme: 'tel', path: value.replaceAll(RegExp(r'[().\-\s]'), ''));
    case 'telegram':
      final username = value.replaceFirst(RegExp(r'^@'), '');
      if (!RegExp(r'^[A-Za-z0-9_]{5,32}$').hasMatch(username)) return null;
      return Uri.https('t.me', '/$username');
    case 'whatsapp':
      final digits = value
          .replaceAll(RegExp(r'[\s().-]'), '')
          .replaceFirst(RegExp(r'^\+'), '');
      if (!RegExp(r'^\d{8,15}$').hasMatch(digits)) return null;
      return Uri.https('wa.me', '/$digits');
    case 'email':
      if (value.length > 254 ||
          !RegExp(r"^[A-Za-z0-9.!#$%&'*+/=_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$").hasMatch(value)) {
        return null;
      }
      return Uri(scheme: 'mailto', path: value);
    case 'website':
    case 'other':
      final uri = Uri.tryParse(value);
      if (uri == null ||
          uri.scheme != 'https' ||
          uri.host.isEmpty ||
          uri.userInfo.isNotEmpty) {
        return null;
      }
      return uri;
    default:
      return null;
  }
}
