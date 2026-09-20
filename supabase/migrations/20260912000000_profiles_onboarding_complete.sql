-- Tracks whether a merchant has finished every step of the signup wizard
-- (not just created an account/profile row), so an interrupted signup can't
-- be mistaken for a completed one when a session is later restored.
alter table public.profiles
  add column if not exists onboarding_complete boolean not null default false;

-- Backfill: existing rows predate this flag entirely, and a non-empty role
-- is the closest signal available for "already using the app" — treat those
-- as already onboarded so this migration doesn't lock out active accounts.
-- Only genuinely brand-new signups (added after this migration runs) are
-- held to the real "finished every wizard step" rule above.
update public.profiles set onboarding_complete = true where role <> '';
