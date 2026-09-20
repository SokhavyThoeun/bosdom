-- Adds an admin-moderation suspension flag to profiles, for the new admin
-- panel (sellers/buyers can be suspended, blocking their API access via
-- get_current_user in auth.py).

alter table public.profiles
  add column if not exists is_suspended boolean not null default false;
