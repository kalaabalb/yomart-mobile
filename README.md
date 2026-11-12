# YoMart Mobile

Flutter customer app for YoMart.

## Features

- Customer registration/login and JWT session restore
- Product/category/brand browsing, search, favorites and cart
- Product detail, order history, profile and address management
- Manual cash payment flow and payment-proof support where configured
- Localized UI and responsive layouts

## Stack and structure

- Flutter/Dart, Provider, GetX, GetStorage
- REST API through shared HTTP services
- lib/screen/ feature screens, lib/models/ API models, lib/services/ network services, lib/shared/widgets/ reusable UI
- Architecture: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- API contract: [docs/API_REFERENCE.md](docs/API_REFERENCE.md)

## Current production/closed-test boundary — 12 November 2026

- App ID: com.yomobiles.client; current version in pubspec.yaml: 1.0.0+5; target SDK 36.
- Production API: https://yomart-api.onrender.com.
- The API is running on the existing Atlas Free database. No paid infrastructure is used.
- The production catalogue is a preview. The app's YOMART_PREVIEW_CATALOG=true mode shows a clear notice, hides illustrative prices and stock, disables add-to-cart/checkout, and blocks the checkout screen. The production API independently blocks order creation and omits price/stock from public product responses.
- Local debug builds default to http://127.0.0.1:3000 unless MAIN_URL is explicitly supplied. The GitHub Actions preview APK overrides MAIN_URL to the production API, supplies the public privacy URL and compiles preview-only catalogue mode.
- A debug APK is for sideload acceptance only, not a Play Store release AAB.

## Release configuration

The former staging API/site was converted to the production environment and there is no separate staging origin. For a production AAB, the app explicitly requires:

- YOMART_BUILD_ENV=production
- MAIN_URL=https://yomart-api.onrender.com
- YOMART_EXPECTED_API_ORIGIN=https://yomart-api.onrender.com
- YOMART_NO_STAGING_API=true
- YOMART_NO_STAGING_SITE=true
- PRIVACY_POLICY_URL set to the final public HTTPS privacy-policy URL
- YOMART_PREVIEW_CATALOG=true for closed testing until actual prices/stock are approved; set false for a fully approved public-sales release

If separate staging services are created later, remove the no-staging flags and supply exact staging-origin denylists.

A manual signed release workflow is available at [android_signed_release.yml](.github/workflows/android_signed_release.yml). It requires repository Actions secrets ANDROID_KEYSTORE_BASE64, ANDROID_STORE_PASSWORD, ANDROID_KEY_PASSWORD, ANDROID_KEY_ALIAS, and repository variable YOMART_PRIVACY_POLICY_URL. The workflow produces a signed AAB and signing-certificate fingerprint. Compare that fingerprint with the Play Console upload certificate before upload. Never commit or send private signing material in chat.

## Build and test

Local development:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug --dart-define=YOMART_PREVIEW_CATALOG=true
```

The CI preview APK build explicitly uses the production API and privacy URL with YOMART_PREVIEW_CATALOG=true. The current split-ABI build is [run 43234715460](https://github.com/kalaabalb/yomart-mobile/actions/runs/43234715460): formatting, analysis and Flutter tests passed; APK build is in progress. It is configured to publish separate arm32, arm64 and x86_64 debug APKs. A separate Android emulator screenshot job has a 10-minute limit and cannot hold up the source/test/APK verification job indefinitely.

A previous production-connected all-ABI debug APK is available from [run 43232961622](https://github.com/kalaabalb/yomart-mobile/actions/runs/43232961622), artifact 13950889093. It is usable for sideload testing but is larger than the split-ABI build. Do not distribute the older artifact from run 43229794520; that one used the local API default.

## Visual evidence

Real deployed React storefront/admin screenshots at desktop and mobile sizes are captured by the web repository's GitHub Actions workflow. Android emulator screenshot capture is part of the Flutter CI workflow. The admin screenshots currently show sign-in only; authenticated dashboard screens require owner login. Do not treat screenshots of an unauthenticated app as proof that checkout/orders work.

## Owner inputs still required for Play

- Final privacy policy and account-deletion URLs with legal publisher/support details and approved retention language
- Android signing secrets and certificate match against the friend's Play Console upload key
- Play Console package/version availability and developer-account testing eligibility
- Physical Android device acceptance and final store listing assets
- Approved ETB price/stock and product specification for each product before public sales (not required for preview-only closed testing)
