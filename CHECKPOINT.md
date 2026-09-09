# Bosdom — Build Checkpoint

## Workflow rule
Do **one task**, `git commit`, then `/clear` the conversation before starting the next.
Check the box here after each commit so we always know where to resume.

Order: **Frontend (Flutter, UI-first with mock data) → Backend (FastAPI) → Integration (wire them together)**
Payment/Escrow is built **last** in both frontend and backend since it's the highest-risk area (money handling).

---

## Phase 1 — Frontend Foundation
- [x] 1.1 Set up project structure (`lib/features/`, `lib/core/`, `lib/shared/`) and folder conventions
- [x] 1.2 Add core dependencies (Riverpod, go_router, http/dio) to `pubspec.yaml`
- [x] 1.3 Set up theming (colors, typography, `ThemeData`) and app shell (`MaterialApp`, root navigation)
- [x] 1.4 Build reusable UI kit (buttons, input fields, cards, loading/error states)
- [x] 1.5 Set up routing skeleton (go_router) with placeholder screens for all main flows

## Phase 2 — Frontend: Auth & Onboarding
- [x] 2.1 Splash / onboarding screens
- [x] 2.2 Sign up screen (retailer vs. supplier role selection) — UI only, mock submit
- [x] 2.3 Login screen — UI only, mock submit
- [x] 2.4 Verification/KYC upload screen (business docs) — UI only

## Phase 3 — Frontend: Core Marketplace
- [x] 3.1 Product/supplier listing screen (browse wholesale catalog) with mock data
- [x] 3.2 Product detail screen (price tiers: sample vs. bulk pricing)
- [x] 3.3 Search & filter UI

## Phase 4 — Frontend: Feature 1 — Sample Gate
- [x] 4.1 "Buy Sample" flow UI (single-unit at consumer price, 1-per-account cap messaging) — built inline in `product_detail_screen.dart`'s sample mode + `sample_gate_provider.dart`, not in the dedicated stub file (see notes)
- [x] 4.2 Sample order confirmation & status screen — done

## Phase 5 — Frontend: Feature 2 — Co-Buying Linker
- [x] 5.1 "Invite to Co-Buy" link generation screen — done
- [x] 5.2 Co-buy pool view (progress toward volume threshold, participants list)
- [x] 5.3 Join-via-invite-link screen — done

## Phase 6 — Frontend: Feature 3 — Chat & Policy Enforcement
- [x] 6.1 ToS/Liability acceptance gate before chat unlocks
- [x] 6.2 Chat UI (message list, input, mock realtime updates)
- [x] 6.3 Off-platform-deal flag/warning UI states

## Phase 7 — Frontend: Profile & Settings
- [x] 7.1 User profile screen (business info, verification badge) — the badge (Become a Seller / Seller Active pill) is real; the profile screen doesn't display actual business info, and its stats row (orders/active/saved) is hardcoded, not live (see notes)
- [x] 7.2 Order history screen
- [x] 7.3 Settings screen — scattered by design across profile sub-pages (language, currency, notification/privacy/ads popups, help/about/report-issue) rather than one unified screen; every sub-page itself is complete, not a stub (see notes)

## Phase 8 — Frontend: Feature 4 — Escrow & Anti-Scam Evidence (payment, last)
- [x] 8.1 Checkout/escrow payment UI (mock payment step) — checkout + payment screens are fully built; the dedicated `escrow_screen.dart` (`/escrow` route) is an orphaned, unused stub file (see notes)
- [x] 8.2 Order tracking screen with escrow status states — `delivery_tracking_screen.dart` is a fully built animated step timeline (mock timestamps); escrow itself is only one static reassurance banner, not real held/released/disputed states (see notes)
- [ ] 8.3 QR scan-to-confirm-delivery screen — does not exist; no QR package in `pubspec.yaml`, no scan code anywhere; delivery tracking is read-only with no user-initiated confirm action
- [ ] 8.4 Dispute flow: video evidence upload screen with countdown window — only a simple text-based report sheet exists (`report_order_sheet.dart`, reason chips + note field); no video/image evidence upload, no countdown window

## Bonus — Additional Frontend Features Built (not in the original phase plan)
Found via a 2026-09-03 full audit; these are real, fully-built, routed buyer-facing features with no corresponding item above.
- [x] Wishlist screen + 5th bottom-nav tab (`features/wishlist/`) — empty state, add-to-cart action
- [x] Cart screen, distinct from checkout (`features/cart/`) — seller-grouped items, swipe-to-remove, move-to-wishlist, feeds checkout's subtotal
- [x] Notifications screen + unread badge on marketplace header (`features/notifications/`), plus a granular notification-settings popup
- [x] Address book (`checkout/screens/address_book_screen.dart`, `add_address_screen.dart`) — full CRUD-style management, usable standalone or from checkout
- [x] Rate & review bottom sheet for delivered orders (`orders/screens/rate_review_sheet.dart`)
- [x] Store/seller profile page (`marketplace/screens/store_profile_screen.dart`) — products tab, reviews tab with star breakdown, seller stats
- [x] Receipt PDF export from order detail (`orders/services/receipt_service.dart`)
- [x] Help & Support hub — FAQ list/detail, Call Us popup, Report an Issue screen, Terms & Privacy Policy screens
- [x] Full English/Khmer localization (`l10n/`) with a dedicated language-switch screen
- [x] "Become a Seller" mini upgrade flow reachable from Profile (`/profile/become-seller`)

---

## Phase 9 — Backend Foundation
- [x] 9.1 Scaffold FastAPI project with `uv` (`bosdom-backend` repo, `app/main.py`, health check) — already built ahead of schedule (see notes)
- [x] 9.2 Set up Supabase project (Postgres + Auth + Storage + Realtime) — Postgres + Auth (JWT verification) in real use; Storage/Realtime not used yet (media is served from local disk, chat has no live Realtime wiring — that's Phase 14.3) (see notes)
- [x] 9.3 Configure `.env` + `pydantic-settings` config module — already built ahead of schedule
- [x] 9.4 Set up SQLAlchemy + migrations, initial migration — SQLAlchemy was already in use; a migration tool was missing entirely (schema was created ad hoc via `Base.metadata.create_all` on startup). Originally added via Alembic, **since replaced with the Supabase CLI's own migration system** (see 2026-09-09 note below and the Phase 10 notes)

## Phase 10 — Backend: Auth & Users
- [x] 10.1 `User` model (retailer/supplier role, verification status) — `Profile.role` already existed; added `Profile.verification_status` (see notes)
- [x] 10.2 Supabase Auth JWT verification middleware/dependency — already built (`auth.py`, JWKS-verified)
- [x] 10.3 `/users/me` endpoint (profile CRUD) — already built as `/profile/me` (`routers/profile.py`)
- [x] 10.4 KYC document upload endpoint (Supabase Storage) — local-disk storage, matching the app's existing avatar/listing-photo pattern (see notes on why not Supabase Storage)

## Phase 11 — Backend: Marketplace
- [x] 11.1 `Product` model (supplier, sample price, bulk price, volume threshold) — already existed as `Listing` (`seller_id`, `price`, `sample_price`, `moq_qty`), see notes
- [x] 11.2 Product CRUD endpoints (supplier-facing) — `POST /listings/me` already existed; added `GET /listings/me`, `PUT /listings/me/{id}`, `DELETE /listings/me/{id}`
- [x] 11.3 Product listing/search endpoints (buyer-facing) — added `GET /listings` (search by `q`/`category`/`seller_id`) and `GET /listings/{id}`

## Phase 12 — Backend: Feature 1 — Sample Gate
- [ ] 12.1 `SampleOrder` model with 1-per-account constraint
- [ ] 12.2 Sample order creation endpoint + enforcement logic

## Phase 13 — Backend: Feature 2 — Co-Buying Linker
- [ ] 13.1 `CoBuyPool` + `CoBuyParticipant` models
- [ ] 13.2 Create pool / generate invite link endpoint
- [ ] 13.3 Join pool via link endpoint
- [ ] 13.4 Threshold-reached → trigger order endpoint

## Phase 14 — Backend: Feature 3 — Chat & Policy
- [ ] 14.1 `Conversation`/`Message` models
- [ ] 14.2 ToS acceptance gate check before message send
- [ ] 14.3 Supabase Realtime wiring for live messages
- [ ] 14.4 Off-platform-contact detection (keyword/pattern flagging) + flagged-user restriction logic

## Phase 15 — Backend: Feature 4 — Escrow & Anti-Scam (payment, last)
- [ ] 15.1 `Order` model with escrow status state machine
- [ ] 15.2 Payment gateway integration (Bakong/Stripe) — hold funds in escrow
- [ ] 15.3 QR generation + QR scan confirm-delivery endpoint
- [ ] 15.4 Dispute model + video evidence upload endpoint (Supabase Storage) with time-window enforcement
- [ ] 15.5 Refund release logic

---

## Phase 16 — Integration
- [ ] 16.1 Wire Flutter auth screens to Supabase Auth + backend `/users/me`
- [ ] 16.2 Wire product listing/detail screens to backend endpoints
- [ ] 16.3 Wire Sample Gate flow end-to-end
- [ ] 16.4 Wire Co-Buying flow end-to-end
- [ ] 16.5 Wire Chat to Supabase Realtime + ToS gate
- [ ] 16.6 Wire profile/order history to backend
- [ ] 16.7 Wire Escrow checkout, QR confirm, dispute upload end-to-end (last)

## Phase 17 — Polish & Submission Prep
- [ ] 17.1 Clean up concept note fragment (Feature 1 description bleed from Feature 3, see `Bosdom_Concept_Note_Recap.md`)
- [ ] 17.2 End-to-end manual QA pass across all 4 features
- [ ] 17.3 Error/empty/loading states audit
- [ ] 17.4 Final documentation pass (README, setup instructions)

---

## Current status
**Next task:** Phase 12 (Backend: Feature 1 — Sample Gate). Other open frontend gaps: 5.1, 5.3, 8.3, 8.4 (see their notes above).

### Notes
- Flutter project lives at `bosdom/` (root of this git repo).
- Folder conventions documented in `bosdom/lib/ARCHITECTURE.md`. Each `features/<name>/` has `screens/` and `widgets/` subfolders; empty dirs hold a `.gitkeep` until populated.
- `bosdom-backend/` and `supabase/` are separate git-tracked/config dirs, intentionally left out of frontend commits until their own phase (9+).
- `flutter analyze` clean after 1.1, 1.2, 1.3, and 1.4.
- 1.2 added `flutter_riverpod`, `go_router`, `dio`, `http` via `flutter pub add` (versions resolved by pub, see `pubspec.lock`).
- 1.3 added `lib/core/theme/` (`app_colors.dart`, `app_text_theme.dart`, `app_theme.dart`) from the Bosdom brand color system (muted crimson `#9B2C2C`). `main.dart` now wraps the app in `ProviderScope` + `MaterialApp` using `AppTheme.light`, with a placeholder `RootScreen` standing in until routing lands in 1.5.
- 1.4 added `lib/shared/widgets/` UI kit: `AppButton` (primary/secondary/outlined/text variants, loading spinner state), `AppTextField` (label + error/helper text wrapper over `TextFormField`), `AppCard` (themed `Card` with optional tap ripple), `AppLoadingIndicator`, `AppErrorView` (message + optional retry button). All pull colors from `AppColors`/`ThemeData` rather than hardcoding. Barrel export at `lib/shared/widgets/widgets.dart`.
- 1.5 added `lib/core/router/app_router.dart` (`GoRouter` config) and `app_shell.dart` (`StatefulShellRoute.indexedStack` bottom-nav shell for the marketplace/chat/profile tabs). Standalone routes (splash, login, signup, sample-gate, co-buying, escrow) sit outside the shell; `/marketplace/:id` nests under the marketplace branch. Each feature folder got one placeholder screen using a new shared `AppPlaceholderScreen` widget (title/subtitle/action buttons) so the flow is click-through-able. `main.dart` now uses `MaterialApp.router`; the temporary `RootScreen` is gone.
- 2.1 rebuilt `lib/features/onboarding/screens/splash_screen.dart` to match the UI reference (`Welcome screen.png`): crimson gradient background, feathered white radial glow behind the logo, "Bosdom" wordmark, tagline, Verified/Secure/Wholesale trust badges, white "Get Started" button (→ signup), "Log in" link, and merchant-only footer note. The two root-level logo files (originally `.svg`, actually raster PNGs wrapped in a Canva/Figma pattern fill that `flutter_svg` couldn't render) were converted to real PNGs and moved into `bosdom/assets/images/` (`bosdom-logo-white.png`, `bosdom-logo-red.png`), registered under `flutter: assets:` in `pubspec.yaml`.
- Retired the `lib/shared/widgets/` custom UI kit (`AppButton`, `AppTextField`, `AppCard`, `AppLoadingIndicator`, `AppErrorView`, `AppPlaceholderScreen` — all deleted) in favor of stock Material 3 widgets (`FilledButton`, `OutlinedButton`, `TextButton`, `TextFormField`, `Card`, `NavigationBar`) styled entirely through `core/theme/app_theme.dart`. `AppTheme.light` now defines a full M3 `ColorScheme` mapping every brand color to its M3 role, plus a pill-shaped `InputDecorationTheme` (white fill, 28px radius) so form fields stay on-brand with zero per-widget styling. All placeholder screens (chat, co_buying, escrow, sample_gate, marketplace, product_detail, profile, signup) were rewritten inline with stock widgets. `lib/ARCHITECTURE.md` updated to note `shared/widgets/` is intentionally empty.
- 2.3 built `lib/features/auth/screens/login_screen.dart` to match the UI reference: crimson header with rounded-square logo badge that extends full-bleed behind the status bar/notch (`Column` + inner `SafeArea(top: false)` instead of wrapping the whole screen, so the header background isn't cut off by the safe-area inset), "Welcome back Merchant" heading, uppercase field captions above pill `TextFormField`s (phone with `+855` prefix + divider, password with visibility toggle), underlined "Forgot Password?" (mock snackbar), pill "Sign In" button (mock → marketplace), pill "Google" button using the real `assets/images/google.svg` (added `flutter_svg` dependency), and underlined "Create Account"/"Google" both routing to `signup` (intended to become the retailer/supplier setup screen). Verified live on iOS Simulator via `flutter run` (temporarily pointing `initialLocation` at `/login`, reverted after).
- 2.2 rebuilt `lib/features/auth/screens/signup_screen.dart` as the "Choose Your Role" step of the signup wizard, matching the two UI references (retailer vs. supplier selection). Same full-bleed crimson header pattern as 2.3, plus a "Back" control (`context.canPop()` → pop, else fall back to `/splash` since routes reached via `goNamed` don't always leave a pop-able stack entry) and a segmented step-progress bar. A `_MerchantRole` enum (`retailer`, `supplier`) carries each role's title/subtitle/icon/step-count — retailer is a 3-step flow, supplier is a 4-step flow (extra KYC step), so the header's "Step 1 of N" and progress-bar segment count update reactively based on the selected `_RoleCard`. Selected card gets a crimson border, filled crimson icon circle, and a check badge next to the title; unselected stays white/outline with a tinted icon circle. "Continue" mock-submits straight to marketplace (no multi-step wizard yet — steps 2+ land in a later phase). Verified both role states live on iOS Simulator (temporarily forcing the default selection and `initialLocation` at `/signup`, both reverted after).
- 2.4 built out the rest of the signup wizard steps 2–4, completing both role flows end to end: `personal_details_screen.dart` (step 2, both roles — name/phone/email/password), `delivery_address_screen.dart` (retailer's final step 3/3 — house/sangkat/province/landmark, ToS agreement, "Create My Account"), `upload_documents_screen.dart` (supplier step 3/4 — National ID required + Passport/Business Certificate optional, mock "Tap to Upload" → "Uploaded" toggle, Continue gated on National ID), and `business_info_screen.dart` (supplier's final step 4/4 — shop name, store type, mock store-photo uploader, online store URL, province/district/street, ToS agreement, "Create my Account"). Routing branches by `MerchantRole` in `personal_details_screen.dart`/`upload_documents_screen.dart`; all new routes registered in `app_router.dart`. Full retailer (3-step) and supplier (4-step) flows verified via automated `flutter test` widget tests (route transitions + disabled-until-agreed button gating), not just eyeballed.
- 3.1 (already largely built ahead of schedule): `marketplace_screen.dart` is the full listing screen — crimson header with logo/notifications/tappable search bar, horizontal category chips, horizontal Co-Buy deal cards with progress bars, and a 2-column product grid with 12 mock wholesale products. Extracted the product model/mock data to `lib/features/marketplace/models/product.dart` (`Product`, `kMockProducts`) and the card UI to `lib/features/marketplace/widgets/product_card.dart` (`ProductCard`) so both the marketplace grid and the new search screen share one source of truth instead of duplicating the mock catalog. Fixed a latent 3.9px `RenderFlex` overflow in the card's text column (surfaced once the shared widget ran on both screens) by tightening `childAspectRatio` from 0.68 to 0.64 on both grids.
- Made the Search tab (`lib/features/search/screens/search_screen.dart`) actually work: live-filtering `TextField` (autofocus, clear button) that matches by product name or seller against `kMockProducts`, results rendered in the same `ProductCard` grid, empty-state message when nothing matches, and tapping a result routes to `productDetail` via the product's index in `kMockProducts`. The marketplace header's "Search products..." bar is now tappable and navigates to the Search tab (`context.goNamed('search')`) instead of being static text. Verified live on iOS Simulator (`flutter run`, temporarily forcing `initialLocation` to `/search`, reverted after) — grid renders cleanly with no overflow; live-typing verification was skipped because this environment lacks Accessibility permission for `osascript` keystroke injection into the simulator, but the filter is a straightforward case-insensitive substring match and `flutter analyze` is clean.
- Phase 6 (6.1–6.3): chat UI itself (`chat_screen.dart`, `chat_detail_screen.dart`) already existed calling a live `bosdom-backend`, but was missing the ToS gate and off-platform detection required by the checkpoint. Added: `lib/features/chat/providers/chat_policy_provider.dart` (`AsyncNotifier<bool>` persisted via `shared_preferences`, key `chat_tos_accepted`) + `lib/features/chat/screens/chat_policy_gate.dart` (`ChatPolicyGate` wrapper — shows a one-time "Chat & Trading Policy" acceptance screen with a checkbox gating a "Continue to Chat" button before rendering its `child`; wraps both `chatList` and `chatDetail` routes in `app_router.dart`). Added `lib/features/chat/utils/off_platform_detector.dart` (`detectsOffPlatformAttempt` — keyword list + phone-number regex), wired into `ChatMessage.flagged` (`conversation.dart`) so any message text matching it renders an amber "Off-platform contact flagged" badge in `_MessageBubble`, plus a live warning banner above the composer as the user types (`_OffPlatformWarningBanner`, driven by a `TextEditingController` listener). Also strengthened "mock realtime" (6.2): added `chatTypingProvider` (`NotifierProvider.family`, since `riverpod: ^3.4.2` no longer exports `StateProvider` — used a plain `Notifier<bool>` family instead) toggled around the `ChatService.sendMessage` await in `chat_provider.dart`, rendered as an animated bouncing-dots `_TypingBubble` at the bottom of the message list while awaiting a reply. Verified live on iOS Simulator via `flutter run` hot restart (router changes need restart, not reload) — `flutter analyze` clean across all touched files.
- 8.1: `checkout_screen.dart` (with `cart_screen.dart`, the checkout progress stepper, and the address book) was already built ahead of schedule and already matched the UI reference pixel-for-pixel — crimson header, Cart→Checkout→Payment stepper, delivery address card (mock "Warehouse District 7, Phnom Penh"), 3-item order summary, and Vireak Buntham Express/J&T Express shipping options. No code changes needed; verified live on iOS Simulator by temporarily forcing `initialLocation` to `/checkout` (reverted after) and comparing a screenshot against the reference.
- 2026-09-03 (ahead of Phase 16, since Google auth was already live): added **native iOS Google Sign-In**. `AuthService.signInWithGoogle()` (`auth_service.dart`) now branches by platform — iOS uses `google_sign_in ^7.2.0`'s native `GoogleSignIn.instance.initialize/authenticate` + `signInWithIdToken`, with the iOS OAuth client in `SupabaseConfig.googleIosClientId` and the reversed-client-ID URL scheme added to `ios/Runner/Info.plist`. **Android has no OAuth client yet**, so it still falls back to the original browser-redirect `signInWithOAuth` flow — don't remove that path (or the `com.example.bosdom` manifest scheme/intent-filter it depends on) until Android gets its own client. Also fixed two bugs found while wiring this up:
  - Google sign-in was bypassing onboarding entirely — accounts got created via the backend's `_get_or_create` with a permanently blank `role`, since role is never read from the Supabase JWT (only set by `personal_details_screen.dart`'s explicit `ProfileService.save()`). Fixed by having `login_screen.dart` check the profile's `role` after any sign-in and route to the `signup` wizard (not `marketplace`) when it's empty; `personal_details_screen.dart` now detects an already-authenticated (Google) session, hides the password fields, pre-fills name/email from the Google account, and skips straight to saving the profile with the role chosen in step 1.
  - `ApiConfig.baseUrl`'s hardcoded dev-machine LAN IP had gone stale, which silently broke every backend call — `ProfileNotifier` swallows the error and falls back to an empty profile with no visible failure, which looked like a Google-auth/migration bug and cost real debugging time. If profile data looks mysteriously empty again, check this before anything else (`ipconfig getifaddr en0`, confirm `uv run uvicorn` is actually running, `curl` the configured `baseUrl`).
  - Also confirmed `bosdom-backend/.env`'s `DATABASE_URL` **is** the live Supabase Postgres (via the pooler, connected as the `postgres` role) — so `supabase/migrations/*.sql`'s trigger/RLS are vestigial for this app (backend bypasses RLS and does its own create-if-missing in `routers/profile.py`). A missing/unpushed migration is not the first thing to suspect when profile data seems wrong.
- 2026-09-03: Full re-audit of the buyer/retailer-facing frontend (seller-only screens and all backend correctness explicitly out of scope) against this checkpoint, because checked/unchecked state had drifted from reality in both directions. Read every screen under `bosdom/lib/features/` plus `app_router.dart`/`app_shell.dart`. Corrections applied above:
  - **Two orphaned dead-code stub screens** are the main source of false "done" marks: `sample_gate/screens/sample_gate_screen.dart` (`/sample-gate` route) and `escrow/screens/escrow_screen.dart` (`/escrow` route) are both literal one-line placeholder screens that are never navigated to from anywhere in the app. The real functionality each was meant to represent was actually built elsewhere instead — the 1-per-account sample cap lives inline in `product_detail_screen.dart` + `sample_gate_provider.dart`, and "escrow" is a fee line-item + reassurance banner inside `checkout_screen.dart`/`delivery_tracking_screen.dart`. Consider deleting both orphaned files/routes or wiring them up for real, since they currently do nothing and could mislead future work.
  - **Previously marked done but actually missing:** 4.2 (sample confirmation/status — no `Order` is ever created for a sample claim), 5.3 (join-via-invite-link — no deep-link handling exists at all). **Downgraded from done to partial-with-caveats:** 5.1 (co-buy invite is a share-sheet button, not a screen, and its link path doesn't match the app's real route), 7.1 (no business-info display on profile; stats are hardcoded), 8.2 (tracking screen is fully built but has no real escrow state machine, just one static banner).
  - **Previously marked not-done but is actually substantially built:** the profile/settings/order-history cluster (7.1–7.3) all turned out to be real, complete screens, not stubs.
  - **Confirmed still genuinely missing:** 8.3 (QR scan-to-confirm-delivery — no QR package or scan code anywhere) and 8.4 (dispute flow only has a simple text report sheet, no video evidence upload or countdown window).
  - Found a large amount of real, fully-built buyer-facing work with no checkpoint item at all (wishlist, cart, notifications, address book, rate & review, store profile page, PDF receipts, help/FAQ hub, English/Khmer localization, a "Become a Seller" upgrade entry point) — added as a new "Bonus" section above rather than silently left untracked.
- 2026-09-09 (Phase 9) — **SUPERSEDED, see the later 2026-09-09 "switch to Supabase migrations" note**: audited `bosdom-backend/` and found it already substantially built ahead of the checkpoint — a live FastAPI app (`uv run uvicorn`) with routers for profile, shop, listings, orders, wishlist, chat, co_buy, notifications, receipts (PDF), ads/marketing consent, backed by real Supabase Postgres (`DATABASE_URL` in `.env`, via the pooler) and Supabase Auth (JWT verified in `auth.py` against the project's JWKS). Marked 9.1–9.3 done to match reality. The one genuine gap was 9.4: `alembic` was listed as a `pyproject.toml` dependency but never actually set up — no `alembic.ini`, no `versions/`; the schema was instead created ad hoc by `Base.metadata.create_all(bind=engine)` on every app startup. Fixed by:
  - `uv run alembic init alembic`, then wired `alembic/env.py` to import `bosdom_backend.models` (registers tables on `Base.metadata`) and pull the DB URL from `Settings.database_url` instead of a static `alembic.ini` value (escaping `%` before handing it to `ConfigParser.set`, since the real Supabase password contains `%` characters that ConfigParser otherwise tries to interpolate).
  - Autogenerating directly against the live Supabase DB surfaced a landmine: that database still has the **original `supabase/migrations/*.sql` tables** (`user_profiles`, `products`, `orders`, `categories`, `co_buy_pools`, `co_buy_participants`, `order_items`) sitting alongside the SQLAlchemy-owned ones (`profiles`, `shops`, `listings`, `order_reports` — different names, per [[project_backend_shares_supabase_postgres]]). Autogenerate wanted to `DROP TABLE` every legacy table plus alter `profiles` column types (UUID→String, TEXT→String) to match what SQLAlchemy reflects — running that migration as generated would have destroyed live production data. **Discarded the autogenerated diff and hand-wrote `alembic/versions/d12220c2f962_initial_schema.py`** to only `CREATE TABLE` the 4 SQLAlchemy-owned tables (matching `models.py` exactly) and touch nothing else. Verified the handwritten migration applies cleanly to a throwaway empty SQLite DB, then ran `alembic stamp head` against the real Supabase DB (tables already existed there from the old `create_all` calls, so this records the baseline as applied without re-running DDL). Removed `Base.metadata.create_all(bind=engine)` from `main.py` — Alembic is now the only thing that creates/changes schema.
  - **If you add or change a model going forward:** run `uv run alembic revision --autogenerate -m "..."` and **always read the generated diff before applying** — the live DB has unrelated legacy tables that autogenerate does not know to ignore, so a blind `alembic upgrade head` could still try to touch them.
- 2026-09-09 (Phase 10): audited `bosdom-backend/` against the checkpoint's own 10.1–10.4 breakdown and found 10.2/10.3 already fully built (JWT verification in `auth.py`, profile CRUD as `/profile/me`), but the checkpoint's own "likely remaining gap" note for 10.4 was itself half-wrong — `Profile` also had no `verification_status` field at all, so 10.1 wasn't actually done either. Fixed both:
  - Added `Profile.verification_status` (`str`, default `"unverified"`) and a new `KycDocument` model (`profile_id`, `doc_type`, `file_url`, `uploaded_at`) to `models.py`.
  - Added `GET/POST /profile/me/kyc-documents` to `routers/profile.py`, storing files to local disk under `media/kyc_documents/` — same pattern as the existing avatar/listing-photo uploads, **not** Supabase Storage as the checkpoint item literally says, since Storage isn't wired up anywhere in this backend yet (per [[project_backend_shares_supabase_postgres]]/9.2 notes: Postgres + Auth are live, Storage/Realtime are not). Revisit if/when Storage gets wired up generally, rather than doing it ad hoc for just this endpoint.
  - Uploading a `national_id` doc immediately sets `verification_status = "verified"` (no separate admin-review step) — matches `upload_documents_screen.dart`'s own copy ("Your Seller badge activates immediately no admin confirmation needed"), so the backend just codifies frontend UX that was already promised but never backed by real state.
  - Hand-wrote the Alembic migration (`e19311b268dc`) rather than using the autogenerated one, same reason as 9.4: autogenerate also wanted to drop the live DB's legacy `supabase/migrations/*.sql` tables and alter unrelated `profiles`/`listings` columns. Migration applied cleanly to the live Supabase DB (`alembic upgrade head`). **Alembic itself was removed later the same day — see the note directly below.**
  - Not done: nothing in the frontend actually calls these new endpoints yet — `upload_documents_screen.dart`'s "Tap to Upload" buttons are still local `setState` toggles with no `image_picker`/API wiring. That's Phase 16 (Integration) territory, not Phase 10.
- 2026-09-09 (later same day): removed Alembic entirely and switched to the **Supabase CLI's own migration system** (`supabase/migrations/*.sql` + `supabase db push --linked`) as the single source of truth for schema, at the user's request — this project already has a linked Supabase project (`supabase/.temp/project-ref`) and a working CLI, so running two migration tools in parallel was redundant. Concretely:
  - Deleted `bosdom-backend/alembic/` and `alembic.ini`, and dropped the `alembic` dependency from `pyproject.toml` (`uv sync` picked up the removal cleanly — `uv run python -c "from bosdom_backend.main import app"` still imports fine).
  - Ported both hand-written Alembic migrations (`d12220c2f962`, `e19311b268dc`) into two new idempotent SQL files: `supabase/migrations/20260909210000_shops_listings_order_reports.sql` (the `shops`/`listings`/`order_reports` tables SQLAlchemy owns, which — unlike `profiles` — never had a `supabase/migrations/*.sql` entry at all) and `20260909210100_kyc_documents_and_verification_status.sql` (today's `kyc_documents` table + `profiles.verification_status`). Both use `create table if not exists` / `add column if not exists` since the live DB already has all of this from the now-deleted Alembic runs — ran `supabase db push --linked` and it correctly no-op'd the DDL while still registering both files in the remote migration history (`supabase migration list --linked` now shows all 3 files in sync, local and remote).
  - **Going forward: schema changes are plain SQL files in `supabase/migrations/`, applied with `supabase db push --linked`.** No more `alembic revision --autogenerate` — write the `CREATE TABLE`/`ALTER TABLE` by hand. The same landmine still applies though: the live DB has legacy tables (`user_profiles`, `products`, `orders`, `categories`, `co_buy_pools`, `co_buy_participants`, `order_items`) that are not owned by this backend — never write a migration that touches them, and there's no autogenerate here to accidentally suggest it.
  - SQLAlchemy models (`models.py`) are unchanged and still the ORM layer for queries — only the schema-migration *tooling* changed, not how the backend talks to Postgres.
- 2026-09-09 (Phase 11): audited `routers/listings.py` per the checkpoint's own hint and found only `POST /listings/me` (create) existed — no list, update, delete, or public browse/search endpoints, and the `Listing` model (`seller_id`, `price`, `sample_price`, `moq_qty`, `stock_qty`, ...) already covered everything 11.1 asked for (`Product` model with supplier/sample price/bulk price/volume threshold) under different field names, so no schema change was needed. Added to `listings.py`:
  - `GET /listings/me` — list the current seller's own listings.
  - `PUT /listings/me/{listing_id}` / `DELETE /listings/me/{listing_id}` — full-form update and delete, both scoped by a shared `_get_owned_listing` helper that 404s (not 403) when the listing doesn't exist or isn't owned by the caller, so ownership isn't leaked. `PUT` mirrors `POST`'s multipart/Form shape (photos optional — only replaces `photo_urls` if new files are uploaded, otherwise keeps the existing ones).
  - `GET /listings` (buyer-facing browse/search, optional `q`/`category`/`seller_id` query params, `q` does a case-insensitive substring match on `product_name`/`description`) and `GET /listings/{listing_id}` (public single-listing fetch). No auth required on either, matching how the frontend's own marketplace/search screens work against mock data today.
  - Route order matters here: `GET /listings/me` is registered before `GET /listings/{listing_id}` so a request for `/listings/me` doesn't get swallowed by the `{listing_id}` path param.
  - No role/seller check gates listing creation or mutation — consistent with the rest of the backend today (nothing else checks `Profile.role` either, per the 10.1 notes), so any authenticated user can create/edit/delete their own listings for now. Revisit if/when role enforcement is added generally.
  - Verified all 6 endpoints (create/list/update/delete/search/get-one, plus the ownership-404 case) against an in-memory SQLite `TestClient` harness (not the live Supabase DB) since this backend has no test suite of its own yet; the scratch script was discarded after passing, not committed.
  - Not done: nothing in the frontend calls any of this yet (frontend still runs entirely on `kMockProducts`) — that's Phase 16 (Integration) territory.

---

## Known issue: bottom "rectangle" strip / content hidden under the floating nav pill

**Symptom.** A dead band of screen-background color along the bottom edge that stops the app looking full-bleed, and/or scroll content resting *underneath* the floating nav pill instead of above it.

**Cause.** `SafeArea` does not add padding — it *shrinks the viewport*. Every screen was written as `SafeArea(top: false, child: <scroll view>)`, so the scroll area physically ends short of the bottom edge and the `Scaffold` background paints in the gap. The size of the gap depends on the route:
- Inside the nav shell, `AppShell` sets `extendBody: true`, which makes Flutter hand the body a `MediaQuery.padding.bottom` equal to the **whole floating pill's height** (68px pill + 16px margin + ~34px home indicator ≈ 118px).
- On pushed routes (detail, checkout, auth, …) there is no pill, so the inset is just the ~34px iOS home indicator.

Because the viewport is cut, content can never travel behind the pill — the glass/blur has nothing under it and the bar stops reading as "floating".

**Fix (the swap).** Keep the viewport full-height and move the inset *inside* the scroll view:

```dart
SafeArea(
  top: false,
  bottom: false,                     // viewport now reaches the physical edge
  child: ListView(
    padding: EdgeInsets.fromLTRB(
      24, 24, 24,
      8 + MediaQuery.of(context).padding.bottom,   // last item rests above the pill
    ),
    ...
```

This gives both behaviours at once: content scrolls *behind* the translucent pill (visible through the blur), and the end of the list still comes to rest clear of it. `SafeArea(bottom: false)` leaves `MediaQuery.padding.bottom` intact for descendants, so the value is still readable inside the scroll view.

**Do not** "fix" this by removing the inset globally (e.g. `MediaQuery.removePadding(removeBottom: true)` around the shell body) — content then runs under the pill permanently. Both halves of the swap are required.

**Done.** All 5 shell tabs (marketplace, search ×3 scroll views, wishlist, cart, profile) + `product_detail_screen.dart` + `store_profile_screen.dart` + `category_results_screen.dart`.

**Remaining — 19 screens** still have the un-swapped pattern (find them with: `grep -rl "SafeArea(" lib/features` then check for `top: false` without `bottom: false`): all 6 auth screens, chat ×2, profile sub-pages ×6, notifications, co_buying.

**Done since:** `checkout_screen.dart`, `address_book_screen.dart`, `add_address_screen.dart` (checkout ×3 — mechanical swap) and `payment_screen.dart` (pinned "Pay Now" bar — inset added to the bar's own bottom padding instead of scroll padding, per the special-handling note above). `flutter analyze` clean on both. `delivery_tracking_screen.dart` (orders — mechanical swap; `orders_screen.dart` and `order_detail_screen.dart` already had the swap, `rate_review_sheet.dart` is a non-scrolling modal sheet so the default `SafeArea(top: false)` bottom inset already covers it, no change needed).

**Also fixed on `orders_screen.dart` — separate bug, same screen:** the filter-chip row (`_FilterRow`) was pinned above the `ListView` of order cards (fixed header + fixed filter row + scrollable list). Since neither had a shadow/elevation, scrolling the list made card content disappear abruptly right under the filter row, reading as if the card were overlapping/colliding with it. Fixed by moving the filter row into the same scrollable area as the cards (`CustomScrollView` with `SliverToBoxAdapter` for the filter row + `SliverList.separated`/`SliverFillRemaining` for cards/empty-state), so it now scrolls away naturally instead of staying fixed. This pattern (fixed crimson header only, everything else — including filter/category chips — scrolls) matches every other screen in the app (`marketplace_screen.dart`, `co_buying_screen.dart`, `address_book_screen.dart`); `orders_screen.dart` was the only screen that had pinned a filter row outside the scroll view. Verified live on iOS Simulator (`initialLocation` forced to `/orders`, reverted after) — `flutter analyze` clean.

**Same collision bug found and fixed on `chat_screen.dart`:** identical shape to the `orders_screen.dart` bug above — the search field was pinned above the `ListView` of conversations, so scrolling made conversation tiles disappear right under the search bar. Fixed the same way: moved into a `CustomScrollView` (`SliverToBoxAdapter` for the search field + `SliverList.separated`/`SliverFillRemaining` for tiles/empty-state), plus applied the standard `SafeArea(top: false, bottom: false)` swap with bottom inset added to the sliver list's padding (this screen was also on the "remaining 20" list above). Verified live on iOS Simulator (`initialLocation` forced to `/chat`, reverted after) — `flutter analyze` clean.

**Four need special handling — not a mechanical swap.** `checkout_screen.dart`, `payment_screen.dart` and `rate_review_sheet.dart` have pinned bottom action bars, and `chat_detail_screen.dart` has a composer above the keyboard. For these the inset belongs on the *pinned bar's* own padding, not on scroll padding — otherwise the button/composer ends up under the gesture bar.

**Rule for new screens:** never wrap a scroll view in `SafeArea` with the bottom enabled. Use `SafeArea(top: false, bottom: false)` + `MediaQuery.of(context).padding.bottom` added to the scroll view's bottom padding. Never change `AppShell`/`FloatingNavBar` to work around a screen-level spacing problem — the nav bar is final.