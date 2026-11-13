import 'package:flutter_test/flutter_test.dart';
import 'package:e_commerce_flutter/utility/privacy_policy_link.dart';

void main() {
  test('accepts a configured HTTPS policy URL without credentials', () {
    expect(
        configuredPrivacyPolicyUri(
                'https://example.invalid/privacy-policy.html')
            ?.path,
        '/privacy-policy.html');
  });

  test('rejects missing, insecure, malformed, credentialed, and fragment URLs',
      () {
    for (final value in [
      '',
      'not a url',
      'http://example.invalid/policy',
      'https://user:pass@example.invalid/policy',
      'https://example.invalid/policy#draft'
    ]) {
      expect(configuredPrivacyPolicyUri(value), isNull, reason: value);
    }
  });
}
