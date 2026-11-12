# YoMart Android and Web Release Checklist

This checklist prepares the Flutter customer app for Android distribution and browser hosting. A successful local build does not mean Google Play will approve the app; Play Console declarations, the real business identity, production services, testing, and review are still required.

## Current Android configuration

- Application ID: `com.yomobiles.client`.
- Current source version: `1.0.0+5` (`versionName` 1.0.0, `versionCode` 5). Confirm the version code against Play Console before a new upload; every update must use a higher code.
- Target and compile SDK: Android API 36, the current Google Play submission minimum for new apps and updates from August 31, 2026.
- Android Gradle Plugin: 8.9.1, the documented minimum for API 36, with Gradle 8.12.
- Release artifacts must be signed using the local release keystore in `android/key.properties`.
- Submit an Android App Bundle (`.aab`) to Play Console. Enable Play App Signing in the Console and keep a secure offline backup of the upload keystore and its passwords.
- iOS is not part of this release plan.
- Flutter 3.44.9 / Dart 3.12.2 is the toolchain observed locally during this audit. The repository does not pin a Flutter SDK version, so reproducible release builds require selecting and pinning an SDK (for example with FVM or CI setup) before release. Static hosting receives built files; it does not compile the Flutter source by itself.
- Current source includes the merged older-cart checkout compatibility fix (merge commit `69c91510c4b26d5c976a46727f28252319e7a109`). Main-branch GitHub Actions run `43207373086` passed format, analysis, Flutter tests, and Android debug APK build; it uploaded `yomart-android-debug-apk`. This artifact is a debug APK, not a signed release AAB. No current release AAB or Play Console screenshot set has been verified. Launcher icon assets are present, but listing images must still be reviewed and uploaded by the owner.

## Before building a production release

1. The API is already running in production on the existing MongoDB Atlas Free cluster, with Cloudinary image storage and authenticated private payment-proof storage. Live health and CORS smoke checks pass. The Free tier does not provide paid-tier backup/availability guarantees; export data regularly. Production checkout is intentionally disabled until real prices and stock are owner-approved. There is currently no separate staging API or storefront origin.
2. Host this web build on a public HTTPS domain. Use that domain for the privacy policy and account deletion resources.
3. Do not edit `web/account-deletion-config.js`; it is intentionally fail-closed. The Android app's release startup validates explicit environment/API defines. Since the former staging API was converted to production and no separate staging site exists, production release builds must explicitly set `YOMART_NO_STAGING_API=true` and `YOMART_NO_STAGING_SITE=true`; the app rejects combining either flag with a nonempty corresponding staging-origin list. If separate staging services are created later, remove these flags and provide exact staging-origin denylists. Configure backend CORS with the exact public web origins.
4. Replace all `REPLACE BEFORE PUBLICATION` content in `web/privacy-policy.html` with the legal publisher name, working support email, and real service-provider details. Reconcile the text against the deployed database, image, push, hosting, and logging providers and their retention settings. Owner/legal approval is still required for the stated anonymized retention of order/payment evidence and its final retention period; do not describe this implementation as erasing all order records.
5. In Play Console, use the same working public URLs:
   - Privacy policy: `https://<web-domain>/privacy-policy.html`
   - Account deletion: `https://<web-domain>/account-deletion.html`
6. Increment `version` in `pubspec.yaml` for every Play upload. `versionName` is the part before `+`; `versionCode` is the integer after `+` and must increase on every release.
7. Accept Android SDK license terms on the build machine using the Android SDK owner’s account. Verify the release keystore with its owner and compare its certificate to the Play Console upload certificate; do not use the example key or commit key files/passwords.

## Android App Bundle

Use the owner-approved pinned Flutter SDK for release builds. This repository has no SDK pin; Flutter 3.44.9 / Dart 3.12.2 is only the locally observed toolchain. From `yomoblies_client/`:

```sh
flutter pub get
flutter analyze
flutter test
: "${PRODUCTION_API_ORIGIN:?Set the verified production API origin}"
: "${PRODUCTION_SITE_ORIGIN:?Set the verified production storefront origin}"
: "${PRIVACY_POLICY_URL:?Set the final public privacy policy URL}"
flutter build appbundle --release \
  --dart-define=MAIN_URL="$PRODUCTION_API_ORIGIN" \
  --dart-define=PRIVACY_POLICY_URL="$PRIVACY_POLICY_URL" \
  --dart-define=YOMART_BUILD_ENV=production \
  --dart-define=YOMART_EXPECTED_API_ORIGIN="$PRODUCTION_API_ORIGIN" \
  --dart-define=YOMART_NO_STAGING_API=true \
  --dart-define=YOMART_NO_STAGING_SITE=true \
  --dart-define=YOMART_PREVIEW_CATALOG=true
```

A manually triggered GitHub Actions workflow is available at `.github/workflows/android_signed_release.yml`. To use it, add repository Actions secrets `ANDROID_KEYSTORE_BASE64`, `ANDROID_STORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, and `ANDROID_KEY_ALIAS`, plus repository variable `YOMART_PRIVACY_POLICY_URL` containing the final public HTTPS privacy-policy URL. Create the base64 value locally with `base64 -w0 android/app/release-key.jks`; never paste the keystore or passwords into chat, commit them, or expose them in logs. The workflow builds the signed AAB and publishes its signing-certificate fingerprint so it can be compared with the Play Console upload certificate before uploading. The upload artifact is `build/app/outputs/bundle/release/app-release.aab`. The `YOMART_PREVIEW_CATALOG=true` define is for closed testing while the live catalogue is still being approved; use `false` for a fully approved public-sales release. The production API currently blocks order creation independently of the client banner. Android release signing requires ignored `android/key.properties` and its referenced keystore. Local ignored signing files exist, but their contents must stay out of chat and source control. The OneSignal app ID is optional only if production push is intentionally disabled; without it, SDK initialization is skipped. Do not upload a build that uses the local preview API, placeholder URLs, or test credentials. Use Play Console’s internal track first and test install, registration/login, browsing, checkout, order history, account deletion, deep links, notifications (if enabled), and tablet/large-screen layouts before production rollout.

The app manifest explicitly declares `INTERNET`; review the merged manifest from the final artifact because Flutter plugins may contribute permissions. Image selection uses the platform picker. Data Safety must account for account/contact/address data, optional delivery coordinates, orders and payment-proof images, and push identifiers if OneSignal is enabled, plus disclosures from the actual hosting/storage providers and SDK versions.

## Browser build

From `yomoblies_client/`:

```sh
: "${PRODUCTION_API_ORIGIN:?Set the verified production API origin}"
: "${STAGING_API_ORIGINS:?Set the verified staging API origin list}"
: "${PRODUCTION_SITE_ORIGIN:?Set the verified production storefront origin}"
: "${STAGING_SITE_ORIGINS:?Set the verified staging storefront origin list}"
: "${PRIVACY_POLICY_URL:?Set the final public privacy policy URL}"
export YOMART_BUILD_ENV=production \
  MAIN_URL="$PRODUCTION_API_ORIGIN" \
  YOMART_EXPECTED_API_ORIGIN="$PRODUCTION_API_ORIGIN" \
  YOMART_STAGING_API_ORIGINS="$STAGING_API_ORIGINS" \
  YOMART_STAGING_SITE_ORIGINS="$STAGING_SITE_ORIGINS" \
  PRIVACY_POLICY_URL="$PRIVACY_POLICY_URL"
node tooling/build_web.mjs
SEO_API_BASE_URL="$PRODUCTION_API_ORIGIN" SEO_SITE_ORIGIN="$PRODUCTION_SITE_ORIGIN" SEO_OUTPUT_DIR=build/web node tooling/generate_seo_catalog.mjs
```

Publish the contents of `build/web/` to a static HTTPS host. Configure the host to serve `index.html` for Flutter client-side routes and keep `privacy-policy.html`, `account-deletion.html`, and `account-deletion-config.js` publicly reachable. The backend must allow the deployed origin and use HTTPS. Verify the browser app on narrow/mobile, tablet, and desktop widths.

## Search engine readiness

- The browser entry page has a concise title and description, social sharing metadata, a language declaration, and the store's brand/PWA metadata. `robots.txt` allows public storefront crawling. The admin app deliberately sends `noindex` metadata; this is an indexing hint, not access control.
- The SEO generator reads public `/products` and `/categories` catalog endpoints. It creates canonical crawlable product pages at `/products/<slug>-<id>/` only for products marked `Verified for public search`, plus category pages at `/categories/<slug>-<id>/` for active categories. Category pages link only to verified products. Product `Product`/`Offer` structured data uses catalog prices, offer prices, stock quantities, and images; the current catalog/client use Birr (ETB), and no ratings are generated. New products default to unverified and stay out of search until an admin confirms the exact product, images, selling price, and stock.
- Only run the generator with the final HTTPS storefront and API origins for production. It refuses non-HTTPS origins except loopback when `SEO_ALLOW_LOCAL_URLS=true`. Do not publish a sitemap or canonical URLs with a fake/local hostname. After deployment, register the site in Google Search Console and submit `https://<web-domain>/sitemap.xml`.
- Product/category SEO pages are static snapshots generated at web build time. Rebuild after catalog changes so names, prices, stock, images, canonical URLs, and sitemap stay current. Static host routing must serve generated `/products/.../` and `/categories/.../` `index.html` files before applying the Flutter SPA fallback to other client routes. The SEO pages link to the Flutter storefront home; exact-product app deep linking is not implemented.
- Build the Flutter web app with `node tooling/build_web.mjs`, then generate SEO files with `SEO_API_BASE_URL=<same API origin> SEO_SITE_ORIGIN=<same public site origin> SEO_OUTPUT_DIR=build/web node tooling/generate_seo_catalog.mjs`. The generator checks these origins against `yomart-build-config.json`, fetches the real API catalog at build time, and refuses to create an empty product sitemap. Treat any generator error as a failed release and do not publish the existing output after it fails. Before publication, verify direct URL refreshes, images, canonical tags, `sitemap.xml`, `robots.txt`, privacy and account-deletion resources, and the Flutter fallback on the chosen static host.
- Use accurate, unique product titles/descriptions and real inventory/prices from the admin-managed catalog. Never add fabricated ratings, prices, offers, business addresses, or structured data to improve ranking.

## Play Console declarations and review

- Complete the store listing with the real app name, accurate screenshots, icon, feature graphic, support contact, and a truthful description of physical electronics sales.
- Complete App access instructions, Content rating, Target audience, Ads, and Data safety forms. List all collected/shared data and purposes based on production SDK settings, hosting logs, payment-proof storage, account data, delivery information, and optional push notifications. The HTML policy is a draft until the required publisher/contact/provider details are replaced and verified.
- The app sells physical products. Google Play’s payment policy says Play Billing must not be used for purchases primarily of physical goods; do not add digital subscriptions or in-app digital products to this checkout without reviewing the separate billing rules.
- If this is a new personal Play developer account created after November 13, 2023, complete the required closed test with at least 12 opted-in testers continuously for 14 days before applying for production access.
- Confirm the Play Console account type and creation date in the owner account. The 12-tester/14-day production-access gate applies to personal accounts created after November 13, 2023; this repository cannot establish whether it applies to your account.
- Prepare and upload the Play listing icon, feature graphic, accurate current phone screenshots (and tablet screenshots if supported), descriptions, category, support email, website and privacy URLs. For translated listings, ensure text-bearing screenshots match the listing language.
- Upload the signed AAB to the internal testing track first, test the Play-delivered install and pre-launch report, then complete any applicable closed test and production-access application. Increase `versionCode` for every upload.
- Review Google’s current policy pages immediately before submission. Requirements and Console forms can change, and approval is decided by Google.

## Official references

- [Target API level requirements](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en)
- [Android Gradle Plugin and API compatibility](https://developer.android.com/build/releases/about-agp)
- [Android App Bundle publishing](https://support.google.com/googleplay/android-developer/answer/9844279?hl=en)
- [Account deletion requirements](https://support.google.com/googleplay/android-developer/answer/13327111?hl=en)
- [Data safety section](https://support.google.com/googleplay/answer/11416267?hl=en)
- [Play listing preview assets](https://support.google.com/googleplay/android-developer/answer/9866151?hl=en)
- [Closed testing requirements](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en)
- [Google Play payments policy](https://support.google.com/googleplay/android-developer/answer/9858738?hl=en)
