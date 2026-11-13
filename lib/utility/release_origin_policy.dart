Set<String> validateReleaseOriginDenylist(
  String value, {
  required String name,
  required bool allowEmpty,
}) {
  if (value.trim().isEmpty) {
    if (allowEmpty) return <String>{};
    throw StateError('$name is required for environment separation.');
  }

  final entries = value.split(',').map((entry) => entry.trim()).toList();
  if (entries.any((entry) => entry.isEmpty)) {
    throw StateError('$name must contain only valid comma-separated origins.');
  }

  final origins = <String>{};
  for (final entry in entries) {
    final uri = Uri.tryParse(entry);
    final host = uri?.host.toLowerCase() ?? '';
    if (uri == null ||
        !uri.hasAuthority ||
        uri.scheme != 'https' ||
        host.isEmpty ||
        host.contains('*') ||
        (uri.path.isNotEmpty && uri.path != '/') ||
        uri.query.isNotEmpty ||
        uri.fragment.isNotEmpty ||
        uri.userInfo.isNotEmpty ||
        host.contains('replace-with') ||
        host.contains('placeholder') ||
        host.contains('your-api-domain') ||
        host == 'example' ||
        host.endsWith('.example') ||
        const {'example.com', 'example.org', 'example.net', 'example.invalid'}
            .contains(host)) {
      throw StateError('$name must contain only valid HTTPS origins.');
    }
    origins.add(uri.origin);
  }
  return origins;
}
