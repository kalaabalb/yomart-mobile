# Galaxy A32 issue 13 — implementation and verification

This records the local implementation prepared on the existing `main` branch. It does not claim physical Galaxy A32 verification.

## Implemented

- **Privacy & Security:** the configured HTTPS `PRIVACY_POLICY_URL` opens in the external browser. Missing or invalid configuration, and launch failures, produce an explicit customer-facing message. No policy URL is embedded in the app. The current legal page is still an unapproved draft and must not be treated as a production policy.
- **Help & Support:** the screen fetches active help content and retailer contacts from the API whenever opened, with loading, refresh, error, empty, and unavailable states. No support contacts or business details are hardcoded. The API and admin changes are documented in their respective repositories; this flow is end-to-end only after those revisions are deployed and approved records are published.
- **Profile editing and picture:** supported profile fields continue through the existing authenticated profile flow. Customers can select an image with Android's system gallery/photo picker, upload, replace, or remove it. The app stores only the API's availability state and retrieves the image through the authenticated profile endpoint. Upload UI validates file type/size and shows progress/errors. Local automated route tests use mock persistence and isolated private local storage; no live database or Cloudinary upload was made. Server-backed persistence in a deployed environment remains to be verified after API deployment.
- **Poster artwork:** home poster artwork uses a responsive reserved image area and `BoxFit.contain`, with text/action outside the image frame to avoid cropping and distortion. The backend does not provide poster destination metadata, so the CTA opens the catalog rather than inventing a destination. No separate poster-detail route exists in this app.
- **Favorites:** the redundant back arrow is hidden when Favorites is a bottom-navigation root; normal pushed-route back navigation remains.
- **Samsung category:** brand-first navigation now enters the shared category catalog, including category selection, sort, brand filter, and shared loading/empty/error behavior.
- **Registration arrow:** its horizontal offset accounts for the containing card and outer page gutters so it aligns with the auth screen edge.
- The existing preview/sales-disabled safeguards remain in place; no products, prices, stock, contacts, or support content were fabricated.

## Automated verification

- `flutter analyze --no-pub`: passed with no issues.
- `flutter test --no-pub`: **36 passed, 0 failed**.
- Targeted profile-image/privacy/catalog tests: **4 passed** during fixture debugging; the complete suite above includes them.
- `dart format --output=none --set-exit-if-changed` on all changed Dart files: passed (16 files, unchanged).
- API `npm test`: **259 passed, 0 failed, 2 skipped** (261 total); `npm audit --audit-level=low`: zero vulnerabilities.
- Admin `npm test`: **22 passed, 0 failed**; staging build passed with its documented staging validation variables.

These tests do not prove live Cloudinary delivery, a deployed API/Admin revision, or a physical device interaction. API and admin deployment is required before the new cross-application flows can work against the live service.

## Preview APK

The current debug preview APK is generated from this source with:

```sh
flutter build apk --debug --no-pub \
  --dart-define=MAIN_URL=https://yomart-api.onrender.com \
  --dart-define=YOMART_PREVIEW_CATALOG=true
```

No `PRIVACY_POLICY_URL` is supplied because the owner has not approved/published that page. This is an installable debug preview for manual testing, not a production release or signed Play artifact. It is noindex/preview-safe at the app feature level and does not enable order submission.

- Fresh artifact: `/home/kalaab/Career/03_GitHub/yomart-publish-review-followup/artifacts/yomart-mobile-galaxy-a32-preview-2026-11-13.apk` (199,772,391 bytes; SHA-256 `c9d3839043b3fbaa5972e658a3717724f16f19ba54a27c5d7995783ea1211a6e`).
- APK metadata inspected with Android `aapt`: application ID `com.yomobiles.client`, version `1.0.0` (code 5), min SDK 24, target SDK 36.
- Flutter reported that Gradle 8.12 / Android Gradle Plugin 8.9.1 will soon fall below its supported build range. The build succeeded; plan a separate toolchain update.

## Device verification and release blockers

No physical Galaxy A32 is attached in this environment (`adb devices -l` returned no devices). The configured Android emulators previously terminated during startup, and no device remains connected; therefore there is no fabricated installation, screenshot, or physical interaction evidence. Install the fresh APK on the Galaxy A32 and check privacy link feedback, profile image selection/upload/replace/remove, support loading/empty/error behavior, Samsung category controls, Favorites navigation, registration-arrow alignment, and complete poster artwork.

The current public privacy/deletion pages remain unapproved drafts. Do not supply a production privacy URL until the owner/legal review and public publication are complete. After committing and deploying the API and admin changes, verify authenticated profile image upload/retrieval and support CRUD against the intended environment. No live database, Cloudinary, or customer records were accessed for this implementation.
