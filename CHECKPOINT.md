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
- [ ] 2.1 Splash / onboarding screens
- [ ] 2.2 Sign up screen (retailer vs. supplier role selection) — UI only, mock submit
- [ ] 2.3 Login screen — UI only, mock submit
- [ ] 2.4 Verification/KYC upload screen (business docs) — UI only

## Phase 3 — Frontend: Core Marketplace
- [ ] 3.1 Product/supplier listing screen (browse wholesale catalog) with mock data
- [ ] 3.2 Product detail screen (price tiers: sample vs. bulk pricing)
- [ ] 3.3 Search & filter UI

## Phase 4 — Frontend: Feature 1 — Sample Gate
- [ ] 4.1 "Buy Sample" flow UI (single-unit at consumer price, 1-per-account cap messaging)
- [ ] 4.2 Sample order confirmation & status screen

## Phase 5 — Frontend: Feature 2 — Co-Buying Linker
- [ ] 5.1 "Invite to Co-Buy" link generation screen
- [ ] 5.2 Co-buy pool view (progress toward volume threshold, participants list)
- [ ] 5.3 Join-via-invite-link screen

## Phase 6 — Frontend: Feature 3 — Chat & Policy Enforcement
- [ ] 6.1 ToS/Liability acceptance gate before chat unlocks
- [ ] 6.2 Chat UI (message list, input, mock realtime updates)
- [ ] 6.3 Off-platform-deal flag/warning UI states

## Phase 7 — Frontend: Profile & Settings
- [ ] 7.1 User profile screen (business info, verification badge)
- [ ] 7.2 Order history screen
- [ ] 7.3 Settings screen

## Phase 8 — Frontend: Feature 4 — Escrow & Anti-Scam Evidence (payment, last)
- [ ] 8.1 Checkout/escrow payment UI (mock payment step)
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
**Next task:** 2.1 — Splash / onboarding screens

### Notes
- Flutter project lives at `bosdom/` (root of this git repo).
- Folder conventions documented in `bosdom/lib/ARCHITECTURE.md`. Each `features/<name>/` has `screens/` and `widgets/` subfolders; empty dirs hold a `.gitkeep` until populated.
- `bosdom-backend/` and `supabase/` are separate git-tracked/config dirs, intentionally left out of frontend commits until their own phase (9+).
- `flutter analyze` clean after 1.1, 1.2, 1.3, and 1.4.
- 1.2 added `flutter_riverpod`, `go_router`, `dio`, `http` via `flutter pub add` (versions resolved by pub, see `pubspec.lock`).
- 1.3 added `lib/core/theme/` (`app_colors.dart`, `app_text_theme.dart`, `app_theme.dart`) from the Bosdom brand color system (muted crimson `#9B2C2C`). `main.dart` now wraps the app in `ProviderScope` + `MaterialApp` using `AppTheme.light`, with a placeholder `RootScreen` standing in until routing lands in 1.5.
- 1.4 added `lib/shared/widgets/` UI kit: `AppButton` (primary/secondary/outlined/text variants, loading spinner state), `AppTextField` (label + error/helper text wrapper over `TextFormField`), `AppCard` (themed `Card` with optional tap ripple), `AppLoadingIndicator`, `AppErrorView` (message + optional retry button). All pull colors from `AppColors`/`ThemeData` rather than hardcoding. Barrel export at `lib/shared/widgets/widgets.dart`.
- 1.5 added `lib/core/router/app_router.dart` (`GoRouter` config) and `app_shell.dart` (`StatefulShellRoute.indexedStack` bottom-nav shell for the marketplace/chat/profile tabs). Standalone routes (splash, login, signup, sample-gate, co-buying, escrow) sit outside the shell; `/marketplace/:id` nests under the marketplace branch. Each feature folder got one placeholder screen using a new shared `AppPlaceholderScreen` widget (title/subtitle/action buttons) so the flow is click-through-able. `main.dart` now uses `MaterialApp.router`; the temporary `RootScreen` is gone.
