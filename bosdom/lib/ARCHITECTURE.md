# Folder conventions

- `core/` — app-wide, feature-agnostic building blocks: `theme/`, `router/`, `constants/`, `errors/`, `utils/`.
- `shared/` — reusable pieces shared across features: `widgets/` (UI kit), `models/`, `providers/` (cross-feature Riverpod providers).
- `features/<feature_name>/` — one folder per product feature (auth, onboarding, marketplace, sample_gate, co_buying, chat, profile, escrow). Each has:
  - `screens/` — top-level pages routed to.
  - `widgets/` — widgets private to that feature.

Feature folders may add `models/` or `providers/` later if a feature needs its own local state that doesn't belong in `shared/`.
