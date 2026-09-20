-- Active/inactive toggle for seller listings (My Inventory screen). Sellers
-- can hide a listing without deleting it; inactive listings are excluded
-- from the buyer-facing marketplace search feed.
alter table public.listings add column if not exists active boolean not null default true;
