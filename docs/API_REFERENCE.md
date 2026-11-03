# API Reference

This client talks to the YoMobiles backend through a shared REST API.

- API base URL: `MAIN_URL` compile-time define. Debug builds default to loopback; release builds require an explicit validated origin and have no hosted fallback.
- HTTP wrapper: [`lib/services/http_services.dart`](../lib/services/http_services.dart)

## Response Envelope

The backend uses a consistent response shape:

- `success`
- `message`
- `data`

## Authentication

All authenticated requests include `Authorization: Bearer <token>`.

The client persists the token in `GetStorage` and restores the session on startup.

| Method | Endpoint | Purpose |
| --- | --- | --- |
| `POST` | `/users/login` | Authenticate a user and receive a JWT plus public user data |
| `POST` | `/users/register` | Register a new user account |
| `GET` | `/users/profile` | Read the currently authenticated user profile |
| `PUT` | `/users/profile` | Update the currently authenticated user profile |
| `GET` | `/users/:id` | Read the signed-in user profile by id |

## Catalog

| Method | Endpoint | Purpose |
| --- | --- | --- |
| `GET` | `/products` | Load the product list |
| `GET` | `/categories` | Load product categories |
| `GET` | `/subCategories` | Load sub-categories |
| `GET` | `/brands` | Load brands |
| `GET` | `/posters` | Load promotional posters |
| `GET` | `/collections` | Load active curated storefront collections |
| `GET` | `/store-settings` | Load active payment options and customer support contacts |
| `GET` | `/stories/published` | Load active, published, successfully stored video stories and short-lived playback URLs |

Story management is restricted to active administrators through `/stories`. Admins manage their own stories; super admins can manage all stories. New uploads are unpublished until an administrator previews and publishes them. The backend requires Cloudinary credentials and an owner-approved `STORY_MAX_DURATION_SECONDS` value before accepting uploads. Video file size is capped at 10 MiB by the current application policy. Public playback URLs are temporary and may remain usable for up to five minutes after unpublishing.

## Orders

| Method | Endpoint | Purpose |
| --- | --- | --- |
| `POST` | `/orders` | Create a new order for the authenticated user |
| `GET` | `/orders/orderByUserId/:userId` | Load the authenticated user order history |
| `GET` | `/orders/:id` | Load a single order owned by the authenticated user |
| `GET` | `/orders` | Customer's own orders; active admin/super admin order list |
| `GET` | `/orders/payment-status/:status` | Admin/super admin payment-status filter |
| `GET` | `/orders/admin/pending-verification` | Admin/super admin payment-review queue |
| `PUT` | `/orders/:id` | Admin/super admin fulfillment status/tracking update |
| `PUT` | `/orders/:id/verify-payment` | Admin/super admin payment decision |
| `PUT` | `/orders/:id/payment-proof` | Customer replacement for eligible own order |
| `DELETE` | `/orders/:id` | Super admin only; evidence-bearing orders cannot be deleted |
| `POST` | `/payment/verify-payment/:orderId` | Admin/super admin payment decision (legacy endpoint) |
| `POST` | `/payment/upload-proof` | Upload a payment proof image |
| `POST` | `/payment/upload-proof-base64` | Upload a payment proof image from a base64 payload |
| `GET` | `/payment/proofs/:orderId` | Stream an order receipt to its owning customer or an active `admin`/`super_admin` |

Payment-proof uploads return only an opaque `proofRecordId`. The customer submits it as `paymentProof.proofRecordId` when creating an order or replacing a proof. The server claims the owner-bound proof record once; reusing it on another order returns a conflict. Replacement requires a new proof and is limited to an unpaid, non-COD order owned by that customer. Order responses omit provider URLs, storage keys, and proof record IDs; they include only availability and review metadata. Receipt bytes are available only through the authorized proof endpoint to the owning customer or an active administrator. Internal receipt lifecycle and operational details are maintained separately from this public client repository.

Admin `GET /users` returns only `_id`, name, email, phone, creation time, and account status; password hashes, verification codes, recovery addresses, and other internal fields are excluded. Customer profile and order endpoints remain owner-scoped.

## Ratings

| Method | Endpoint | Purpose |
| --- | --- | --- |
| `GET` | `/ratings/product/:productId` | Load paginated ratings for a product |
| `GET` | `/ratings/product/:productId/stats` | Load rating statistics for a product |
| `GET` | `/ratings/product/:productId/user/:userId` | Load the authenticated user rating for a product |
| `POST` | `/ratings` | Create or update the authenticated user rating |
| `PUT` | `/ratings/:ratingId` | Update the authenticated user rating |
| `DELETE` | `/ratings/:ratingId` | Delete the authenticated user rating |

## Notes

- The client does not rely on unauthenticated access for private data.
- `GET /orders` is available to admin users in the backend, but the client uses the user-scoped order-history endpoint.
- If the backend contract changes, update the corresponding models and session handling together.
