# Android Release Signing

This project uses a local, gitignored release signing setup.

## Required files

- `android/key.properties`
- a local release keystore referenced by `storeFile`

## Setup

1. Copy `android/key.properties.example` to `android/key.properties`.
2. Point `storeFile` at your local release keystore.
3. Fill in the keystore password, key alias, and key password.
4. Keep both files out of git.

## Example build

```bash
flutter build apk --release \
  --dart-define=MAIN_URL=https://<production-api-domain> \
  --dart-define=PRIVACY_POLICY_URL=https://<web-domain>/privacy-policy.html \
  --dart-define=YOMART_BUILD_ENV=production \
  --dart-define=YOMART_EXPECTED_API_ORIGIN=https://<production-api-domain> \
  --dart-define=YOMART_STAGING_API_ORIGINS=https://<staging-api-domain> \
  --dart-define=YOMART_STAGING_SITE_ORIGINS=https://<staging-store-domain>
```

## CI notes

For CI, inject the keystore and `key.properties` content from your secret store at build time.
Do not commit signing secrets into the repository.
