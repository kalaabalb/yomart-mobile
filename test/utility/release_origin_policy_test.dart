import 'package:flutter_test/flutter_test.dart';
import 'package:e_commerce_flutter/utility/release_origin_policy.dart';

void main() {
  test('staging may omit unconfirmed production origins', () {
    expect(
      validateReleaseOriginDenylist(
        '',
        name: 'production origins',
        allowEmpty: true,
      ),
      isEmpty,
    );
  });

  test('non-empty lists are normalized and strictly validated', () {
    expect(
      validateReleaseOriginDenylist(
        'https://store.example.test/',
        name: 'staging origins',
        allowEmpty: false,
      ),
      {'https://store.example.test'},
    );
    for (final invalid in [
      '',
      'https://*.example.test',
      'https://store.example.test/path',
      'https://user@store.example.test',
      'https://store.example.test?preview=1',
      'https://first.example.test,',
    ]) {
      expect(
        () => validateReleaseOriginDenylist(
          invalid,
          name: 'origins',
          allowEmpty: false,
        ),
        throwsStateError,
        reason: 'Expected rejection for $invalid',
      );
    }
  });
}
