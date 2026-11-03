# Configuration

## Runtime Values

The app reads its API base URL from the `MAIN_URL` compile-time define. Debug builds default to `http://127.0.0.1:3000`; release builds have no default API host.

For Flutter web, use the repository build wrapper so the customer app and account-deletion page receive the same validated API origin:

```bash
YOMART_BUILD_ENV=local \
MAIN_URL=http://127.0.0.1:3000 \
YOMART_EXPECTED_API_ORIGIN=http://127.0.0.1:3000 \
PRIVACY_POLICY_URL=http://127.0.0.1:3000/privacy-policy.html \
node tooling/build_web.mjs
```

For staging, set `YOMART_BUILD_ENV=staging`, `MAIN_URL` and `YOMART_EXPECTED_API_ORIGIN` to the exact same staging API origin, `YOMART_PRODUCTION_API_ORIGINS` to the comma-separated production API origin denylist, and `PRIVACY_POLICY_URL` to the staging HTTPS policy page. For future production, use `YOMART_BUILD_ENV=production`, explicitly set the production API as both `MAIN_URL` and `YOMART_EXPECTED_API_ORIGIN`, and provide `YOMART_STAGING_API_ORIGINS` as the comma-separated staging API origin denylist. The wrapper rejects missing or inconsistent values, localhost outside local mode, reserved placeholder domains, and a URL that appears in the opposite-environment denylist. These are public URLs, never secrets.

Other runtime values are sourced from the app or platform state:

- OneSignal initialization in `lib/main.dart`
- relative image paths returned by the API are resolved against `MAIN_URL`; absolute media URLs are preserved

## Sessions and Local Storage

The app uses `GetStorage` to persist:

- `auth_token` for the signed JWT access token
- `USER_INFO_BOX` for the current user profile payload

On startup, the app validates the stored session with `GET /users/profile`.

If the session is invalid or expired, the app clears the stored auth data and falls back to the login screen.

## Secrets

Do not commit:

- API keys
- push notification credentials
- Stripe secrets
- backend tokens
- private staging URLs

Use environment variables, compile-time defines, or platform-specific configuration files instead.

## Local Development

- Install Flutter and fetch dependencies with `flutter pub get`
- Start the backend before launching the app
- Override `MAIN_URL` when testing against a local backend
- Pass the OneSignal app ID with `--dart-define=ONE_SIGNAL_APP_ID=YOUR_ONESIGNAL_APP_ID` when launching or building. Without it, push initialization and the notification permission prompt are skipped.
- Delivery location selection uses OpenStreetMap tiles through `flutter_map`; it does not need a Google Maps API key. Map tiles are loaded only as users view the map, cached according to server headers, and attributed on screen. The default public OSM tile service is community funded and best effort, so review its [tile usage policy](https://operations.osmfoundation.org/policies/tiles/) before production traffic grows. The tile URL can be changed at build time with `--dart-define=OSM_TILE_URL=https://your-tile-provider/{z}/{x}/{y}.png` if you later choose a different OSM-compatible provider.

## Backend Contract

The app expects the backend to expose the routes documented in [`docs/API_REFERENCE.md`](API_REFERENCE.md).

The current client flow depends on:

- JWT-based user authentication
- `/users/profile` for session restore and profile reads
- `/users/profile` for profile updates
- `/orders/orderByUserId/:userId` for order history

## Storage

`GetStorage` and `flutter_cart` are used for local state.

Keep sensitive data out of local storage unless there is an explicit retention policy.
