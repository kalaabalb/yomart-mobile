# YoMart Mobile

Flutter customer application for the YoMart marketplace.

This repository contains the customer-facing app used to browse products, manage favorites and cart state, place orders, upload payment proof, and maintain the signed-in user profile.

## Who Uses It

- shoppers using the mobile client
- returning users with stored sessions

## Key Features

- user registration and login
- JWT session restore on startup
- product catalog browsing
- category, brand, and sub-category browsing
- product details and ratings
- favorites
- cart management
- order creation and order history
- profile editing
- address storage
- payment proof upload flow
- localized UI strings

## Technology Stack

- Flutter
- Provider for state management
- GetX for navigation, dialogs, and lightweight services
- GetStorage for local session and preference storage
- REST API integration through a shared HTTP service
- `flutter_cart` for cart persistence
- `cached_network_image` for remote media

## Architecture

The app follows a feature-oriented Flutter structure:

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
- [`docs/FOLDER_STRUCTURE.md`](docs/FOLDER_STRUCTURE.md)
- [`docs/API_REFERENCE.md`](docs/API_REFERENCE.md)

High-level responsibilities:

- `lib/core/data/` owns translations and app-wide data loading
- `lib/models/` contains JSON-backed data models
- `lib/services/` contains the shared HTTP layer
- `lib/screen/` contains feature screens and providers
- `lib/shared/widgets/`, `lib/widget/`, and `lib/utility/` contain reusable UI and helpers

## Authentication and Security Model

- The client stores the JWT access token and user payload in `GetStorage`.
- Stored sessions are validated on startup by calling `/users/profile`.
- Invalid or expired sessions are cleared automatically.
- API requests use the `Authorization: Bearer <token>` header for protected routes.
- Do not commit API keys, backend tokens, or private credentials.

## API and Integration Model

- The API base URL is supplied through the `MAIN_URL` compile-time define.
- Debug builds default to the local backend at `http://127.0.0.1:3000`.
- Flutter release builds require explicit `YOMART_BUILD_ENV`, `MAIN_URL`, `YOMART_EXPECTED_API_ORIGIN`, `PRIVACY_POLICY_URL`, and the opposite-environment API and storefront-origin denylists; the app fails on startup when these disagree or target an unsafe host. For web releases, use `node tooling/build_web.mjs`; it validates those values, generates the account-deletion page's API configuration, clears stale output on failure, and scans the artifact for placeholder/localhost endpoints.
- Build a local web preview against the local API with `YOMART_BUILD_ENV=local MAIN_URL=http://127.0.0.1:3000 YOMART_EXPECTED_API_ORIGIN=http://127.0.0.1:3000 PRIVACY_POLICY_URL=http://127.0.0.1:3000/privacy-policy.html node tooling/build_web.mjs`.
- Build staging web with `YOMART_BUILD_ENV=staging MAIN_URL=https://<staging-api-origin> YOMART_EXPECTED_API_ORIGIN=https://<staging-api-origin> YOMART_PRODUCTION_API_ORIGINS=https://<current-production-api-origin> YOMART_PRODUCTION_SITE_ORIGINS=https://<current-production-store-origin> PRIVACY_POLICY_URL=https://<staging-store-origin>/privacy-policy.html node tooling/build_web.mjs`. `MAIN_URL` must be the staging API; provide all production API and storefront origins in their corresponding denylists. Keep these public origins in reviewed deployment configuration.
- After a web build, generate static SEO product pages and a sitemap from the public catalog API with `SEO_API_BASE_URL=https://<api-origin> SEO_SITE_ORIGIN=https://<store-origin> SEO_OUTPUT_DIR=build/web node tooling/generate_seo_catalog.mjs`. The generator checks both origins against `yomart-build-config.json` emitted by the web build wrapper, preventing SEO output from silently using a different API/site. Only products explicitly verified in the admin are included.
- Verify the SEO generator locally with `node --test tooling/generate_seo_catalog.test.mjs`.
- Verify web target generation with `node --test tooling/account_deletion_config.test.mjs`.
- Shared API details are documented in [`docs/API_REFERENCE.md`](docs/API_REFERENCE.md).
- The backend lives in the sibling repository [YoMart API](https://github.com/kalaabalb/yomart-api).
- The customer app connects to the YoMart API; the admin dashboard is maintained as a separate application.

## Visual QA and screenshots

The repository does not currently contain the screenshot files referenced by earlier documentation. Do not treat those historical paths as available evidence.

A current release evidence set still needs to be captured from the actual app on physical Android devices or a verified emulator, with the build commit/version and device/OS recorded. Required screens include splash, home, categories/brands, product details, cart, checkout, payment method, proof submission where applicable, order confirmation, order list/details/tracking, profile, and important loading/empty/error states.

For web/admin, capture desktop and narrow mobile/tablet layouts after the live staging journeys have been exercised. Redact names, emails, phone numbers, addresses, order identifiers, receipts, tokens, and other personal information before sharing. See the shared [closed-testing playbook](https://github.com/kalaabalb/yomart-docs/blob/main/docs/launch/closed-testing-playbook.md) for the evidence checklist.

## Local Setup

### Prerequisites

- Flutter SDK 3.0 or newer
- Dart 3
- A connected device, emulator, or desktop target

### Setup

```bash
git clone <repo-url>
cd yomart-mobile
flutter pub get
```

### Run

```bash
flutter run --dart-define=MAIN_URL=http://127.0.0.1:3000
```

## Configuration

- API base URL is provided through the `MAIN_URL` compile-time define. Release builds have no localhost default.
- User sessions are stored in `GetStorage` as `auth_token` and `USER_INFO_BOX`.
- Add `--dart-define=ONE_SIGNAL_APP_ID=<app-id>` using the ID from your OneSignal dashboard to enable push setup and the Android notification permission prompt. The app records the system permission result and prompts at most once.
- The app expects the backend endpoints documented in [`docs/API_REFERENCE.md`](docs/API_REFERENCE.md).

## Testing

```bash
flutter test
flutter analyze
flutter build appbundle --release \
  --dart-define=MAIN_URL=https://<production-api-domain> \
  --dart-define=PRIVACY_POLICY_URL=https://<web-domain>/privacy-policy.html \
  --dart-define=YOMART_BUILD_ENV=production \
  --dart-define=YOMART_EXPECTED_API_ORIGIN=https://<production-api-domain> \
  --dart-define=YOMART_STAGING_API_ORIGINS=https://<staging-api-domain> \
  --dart-define=YOMART_STAGING_SITE_ORIGINS=https://<staging-store-domain>
flutter build linux --release \
  --dart-define=MAIN_URL=https://<staging-api-domain> \
  --dart-define=PRIVACY_POLICY_URL=https://<staging-web-domain>/privacy-policy.html \
  --dart-define=YOMART_BUILD_ENV=staging \
  --dart-define=YOMART_EXPECTED_API_ORIGIN=https://<staging-api-domain> \
  --dart-define=YOMART_PRODUCTION_API_ORIGINS=https://<production-api-domain> \
  --dart-define=YOMART_PRODUCTION_SITE_ORIGINS=https://<production-store-domain>
```

The repository currently includes smoke coverage for app startup.

## Deployment / Current Status

- Android release signing must be configured locally with gitignored signing files as described in [`android/RELEASE_SIGNING.md`](android/RELEASE_SIGNING.md).
- Android builds target API 36. Review [`docs/PLAY_STORE_AND_WEB_RELEASE.md`](docs/PLAY_STORE_AND_WEB_RELEASE.md) for production backend, privacy, account-deletion, web hosting, and Play Console requirements before release.
- Internal launch audits and operational runbooks are maintained separately and are not part of this public client repository.
- Browser policy resources are available at `/privacy-policy.html` and `/account-deletion.html` after hosting the web build. The web build wrapper generates `account-deletion-config.js` from the validated `MAIN_URL`; do not edit the checked-in fail-closed file.
- Linux release builds currently pass locally.
- GitHub Actions runs format, analyze, and test on pushes and pull requests.

## Known Limitations

- The app still depends on the backend being reachable at the configured API base URL.
- OneSignal and release signing require local environment setup before a production build.
- The screenshot set is representative rather than exhaustive.

## Future Improvements

- Expand GitHub Actions with device/emulator coverage when the test matrix needs it.
- Capture additional screenshots as the UI stabilizes.
- Expand integration tests around order and payment flows.

## Release Notes

- [`CHANGELOG.md`](CHANGELOG.md)
- [`docs/RELEASE.md`](docs/RELEASE.md)
- [`docs/RELEASE_NOTES.md`](docs/RELEASE_NOTES.md)

## Contributing

- [`CONTRIBUTING.md`](CONTRIBUTING.md)
- Keep the feature folders, screenshots, and API docs aligned with any behavior change.
- GitHub Actions, issue templates, and a pull request template are configured under [`.github/`](.github/).

## Security

- [`SECURITY.md`](SECURITY.md)

Do not commit API keys, tokens, or private backend credentials.

## License

MIT License. See [`LICENSE`](LICENSE).

## Author

Yonas Ambelu
