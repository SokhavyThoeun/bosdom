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
- [x] 4.1 "Buy Sample" flow UI (single-unit at consumer price, 1-per-account cap messaging)
- [x] 4.2 Sample order confirmation & status screen

## Phase 5 — Frontend: Feature 2 — Co-Buying Linker
- [x] 5.1 "Invite to Co-Buy" link generation screen
- [x] 5.2 Co-buy pool view (progress toward volume threshold, participants list)
- [x] 5.3 Join-via-invite-link screen

## Phase 6 — Frontend: Feature 3 — Chat & Policy Enforcement
- [x] 6.1 ToS/Liability acceptance gate before chat unlocks
- [x] 6.2 Chat UI (message list, input, mock realtime updates)
- [x] 6.3 Off-platform-deal flag/warning UI states

## Phase 7 — Frontend: Profile & Settings
- [ ] 7.1 User profile screen (business info, verification badge)
- [ ] 7.2 Order history screen
- [ ] 7.3 Settings screen

## Phase 8 — Frontend: Feature 4 — Escrow & Anti-Scam Evidence (payment, last)
- [x] 8.1 Checkout/escrow payment UI (mock payment step)
- [ ] 8.2 Order tracking screen with escrow status states
- [ ] 8.3 QR scan-to-confirm-delivery screen
- [ ] 8.4 Dispute flow: video evidence upload screen with countdown window

---

## Phase 9 — Backend Foundation
- [ ] 9.1 Scaffold FastAPI project with `uv` (`bosdom-backend` repo, `app/main.py`, health check)
- [ ] 9.2 Set up Supabase project (Postgres + Auth + Storage + Realtime)
- [ ] 9.3 Configure `.env` + `pydantic-settings` config module
- [ ] 9.4 Set up SQLAlchemy + Alembic, initial migration

## Phase 10 — Backend: Auth & Users
- [ ] 10.1 `User` model (retailer/supplier role, verification status)
- [ ] 10.2 Supabase Auth JWT verification middleware/dependency
- [ ] 10.3 `/users/me` endpoint (profile CRUD)
- [ ] 10.4 KYC document upload endpoint (Supabase Storage)

## Phase 11 — Backend: Marketplace
- [ ] 11.1 `Product` model (supplier, sample price, bulk price, volume threshold)
- [ ] 11.2 Product CRUD endpoints (supplier-facing)
- [ ] 11.3 Product listing/search endpoints (buyer-facing)

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
**Next task:** 7.1 — User profile screen (business info, verification badge)

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

**Remaining — 25 screens** still have the un-swapped pattern (find them with: `grep -rl "SafeArea(" lib/features` then check for `top: false` without `bottom: false`): all 6 auth screens, chat ×3, checkout ×3, orders ×4, profile sub-pages ×6, payment, notifications, co_buying.

**Four need special handling — not a mechanical swap.** `checkout_screen.dart`, `payment_screen.dart` and `rate_review_sheet.dart` have pinned bottom action bars, and `chat_detail_screen.dart` has a composer above the keyboard. For these the inset belongs on the *pinned bar's* own padding, not on scroll padding — otherwise the button/composer ends up under the gesture bar.

**Rule for new screens:** never wrap a scroll view in `SafeArea` with the bottom enabled. Use `SafeArea(top: false, bottom: false)` + `MediaQuery.of(context).padding.bottom` added to the scroll view's bottom padding. Never change `AppShell`/`FloatingNavBar` to work around a screen-level spacing problem — the nav bar is final.
