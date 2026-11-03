import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

String orderRequestFingerprint(Map<String, dynamic> request) =>
    sha256.convert(utf8.encode(jsonEncode(request))).toString();

String newOrderIdempotencyKey({Random? random}) {
  final source = random ?? Random.secure();
  final bytes = List<int>.generate(16, (_) => source.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

String retainOrderIdempotencyKey({
  required Map<String, dynamic> request,
  required String? previousFingerprint,
  required String? previousKey,
}) {
  final fingerprint = orderRequestFingerprint(request);
  if (fingerprint == previousFingerprint && previousKey != null && previousKey.isNotEmpty) {
    return previousKey;
  }
  return newOrderIdempotencyKey();
}
