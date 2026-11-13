# Galaxy A32 Issue 13 — implementation and verification status

This document records the local implementation prepared on the `main` branch for GitHub issue #13. It does not claim physical Galaxy A32 validation.

## Changes implemented

- Preview mode is now the safe source default. Preview catalog UI omits unapproved prices and stock, removes the repeated page banners, and keeps add-to-cart, checkout, and order submission unavailable. The production API remains responsible for enforcing its own order restrictions.
- Product image loading uses a YoMart gold-mark shimmer, with a static branded treatment when reduced motion is enabled. Image errors no longer log raw URLs or error details, and placeholder sizing is bounded for compact cards.
- Poster images use a responsive height and contain fit. Poster navigation clears search and opens the catalog rather than interpreting promotional copy as a query. The Samsung shortcut opens its real brand catalog route.
- Registration navigation aligns to the established edge; logout confirmation spacing and hierarchy are improved; the empty Saved Destinations action is centered; and product cards use a more compact grid ratio and bounded image area.
- Product detail background begins above the safe area to remove the top seam.
- The app applies light/dark palette changes through one immediate root theme wrapper. Home entry animation starts after its first frame without requiring another route change.
- The support empty state is intentional and uses configured retailer contacts only. No fallback phone number, email, or social account was added.
- Removed the local-only profile-photo picker and its saved-file behavior. The current backend user model and profile routes expose no profile-image field or upload endpoint, so there is no approved server-backed storage path to implement. The UI no longer claims that a device-local image was saved as the account profile image.
- The privacy link remains externally configured. The app does not embed or present an unapproved legal draft as final.
- The existing launcher foreground measured 432×432 pixels and its visible mark is horizontally centered within the image and adaptive-icon safe region. No icon asset change was justified by the source measurement.

## Regression checks

New tests cover safe preview defaults and price suppression, poster search/navigation behavior, the Samsung brand route, first-frame animation start, compact product-card overflow/price suppression, root dark-mode switching, and release-origin denylist validation. Existing Flutter behavior tests remain in the suite.

## Local validation

- `flutter analyze --no-pub`: passed with no issues.
- `flutter test --no-pub`: passed, 31 tests.
- `node --test tooling/account_deletion_config.test.mjs`: passed, 11 tests.
- `git diff --check`: passed.
- Android debug APK build: passed with preview catalog mode enabled and API origin set to `https://yomart-api.onrender.com`. Artifact: `build/app/outputs/flutter-apk/app-debug.apk` (183,019,588 bytes; SHA-256 `d0b8c9f7ff76c8ec366c7ffcbdf029f1bfb1ba911b75103e890ae727ab47c171`). It was built for internal manual testing only; it is not a signed production release.
- APK metadata: application ID `com.yomobiles.client`; version `1.0.0` (code 5); min SDK 24; target SDK 36.

## Device verification and remaining limitations

No physical Samsung Galaxy A32 is connected. The available Android API 36 emulator process terminated with exit code 139 during startup on both configured phone AVD attempts, and no device remained attached. APK installation, runtime log inspection, and device screenshots could not be completed here. The user should install and check the APK on the Galaxy A32 and provide genuine before/after screenshots for the documentation repository. The user should install and check the APK on the Galaxy A32 and provide genuine before/after screenshots for the documentation repository. No screenshot evidence is fabricated or included by this change.

The profile-image upload/save/display flow remains blocked until the backend provides an authorized profile-image field and upload/retrieval route backed by the approved storage architecture. No backend change or local-only avatar fallback was introduced.

The APK is a debug preview build; its catalog is read-only and purchasing is disabled. The production policy URL has not been approved, so this artifact must not be treated as a public production release.

## Commit

Implementation commit SHA: `75d5b340a5f8f9355e6a9adbf3c70aa4a8f72bcf` on `main`.
