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
- `lib/screen/` feature screens, `lib/models/` API models, `lib/services/` network services, `lib/shared/widgets/` reusable UI
- Architecture: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- API contract: [docs/API_REFERENCE.md](docs/API_REFERENCE.md)

## Current production/closed-test boundary — 12 November 2026

- App ID: `com.yomobiles.client`; current version in `pubspec.yaml`: `1.0.0+5`; target SDK 36.
- Production API: `https://yomart-api.onrender.com`.
- The API is running on the existing Atlas Free database. No paid infrastructure is used.
- The production catalogue is a preview. The app's `YOMART_PREVIEW_CATALOG=true` mode shows a clear notice, hides illustrative prices and stock, disables add-to-cart/checkout, and blocks the checkout screen. The production API independently blocks order creation and omits price/stock from public product responses.
- Debug builds default to local API `http://127.0.0.1:3000`; release builds require explicit validated API/privacy/environment defines.
- A successful debug APK is not a Play Store release AAB.

## Release configuration

The former staging API/site was converted to the production environment and there is no separate staging origin. For a production AAB, the app explicitly requires:

- `YOMART_BUILD_ENV=production`
- `MAIN_URL=https://yomart-api.onrender.com`
- `YOMART_EXPECTED_API_ORIGIN=https://yomart-api.onrender.com`
- `YOMART_NO_STAGING_API=true`
- `YOMART_NO_STAGING_SITE=true`
- `PRIVACY_POLICY_URL` set to the final public HTTPS privacy-policy URL
- `YOMART_PREVIEW_CATALOG=true` for closed testing until actual prices/stock are approved; set false for a fully approved public-sales release

If separate staging services are created later, remove the no-staging flags and supply exact staging-origin denylists.

A manual signed release workflow is available at [android_signed_release.yml](.github/workflows/android_signed_release.yml). It requires repository Actions secrets `ANDROID_KEYSTORE_BASE64`, `ANDROID_STORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`, and repository variable `YOMART_PRIVACY_POLICY_URL`. The workflow produces a signed AAB and signing-certificate fingerprint. Compare that fingerprint with the Play Console upload certificate before upload. Never commit or send private signing material in chat.

## Build and test

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug --dart-define=YOMART_PREVIEW_CATALOG=true
```

GitHub Actions builds a preview-mode debug APK and captures genuine Android emulator startup/login screenshots. The current main-branch run is [43228782612](https://github.com/kalaabalb/yomart-mobile/actions/runs/43228782612): formatting, analysis and Flutter tests passed; the Android debug build and emulator screenshots are still running. Earlier debug APK artifacts predate the final preview/splash changes and must not be distributed as the current build.

## Visual evidence

Real deployed React storefront/admin screenshots at desktop and mobile sizes are captured by the web repository's GitHub Actions workflow. Android emulator screenshot capture is part of the current Flutter CI workflow. The admin screenshots currently show sign-in only; authenticated dashboard screens require owner login. Do not treat screenshots of an unauthenticated app as proof that checkout/orders work.

## Owner inputs still required for Play

- Approved ETB price/stock and product specification for each product
- Final privacy policy and account-deletion URLs with legal publisher/support details
- Keystore certificate match against the friend's Play Console upload key
- Play Console package/version availability and developer-account testing eligibility
- Physical Android device acceptance and final store listing assets
