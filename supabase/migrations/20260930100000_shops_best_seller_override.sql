-- "Best Seller" is normally earned automatically once a shop has stayed on
-- the platform long enough (see is_long_tenured_seller in the backend), but
-- admins need to grant or revoke it manually too (e.g. after a shop goes
-- inactive or its sales drop). Null = automatic; true/false = admin override.
alter table public.shops add column if not exists best_seller_override boolean;
