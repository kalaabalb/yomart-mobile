const bool _isReleaseBuild = bool.fromEnvironment('dart.vm.product');
const String mainUrl = String.fromEnvironment(
  'MAIN_URL',
  defaultValue: _isReleaseBuild ? '' : 'http://127.0.0.1:3000',
);
const String privacyPolicyUrl = String.fromEnvironment('PRIVACY_POLICY_URL');

// Keep all your other constants:
const favoriteProductBox = 'FAVORITE_PRODUCT_BOX';
const userInfoBox = 'USER_INFO_BOX';

const phoneKey = 'PHONE_KEY';
const streetKey = 'STREET_KEY';
const cityKey = 'CITY_KEY';
const stateKey = 'STATE_KEY';
const postalCodeKey = 'POSTAL_CODE_KEY';
const countryKey = 'COUNTRY_KEY';

/// Resolves a server-provided media path against the configured API host.
/// Absolute URLs keep their original scheme and host.
String resolveMediaUrl(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) return '';

  final uri = Uri.tryParse(raw);
  if (uri == null || uri.hasScheme) return raw;

  final base = Uri.parse(mainUrl);
  final basePath = base.path.endsWith('/') ? base.path : '${base.path}/';
  return base.replace(path: basePath).resolveUri(uri).toString();
}
