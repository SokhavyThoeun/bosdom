-- Wholesale spec fields shown on the product detail screen (weight, origin,
-- grade, packaging) — sellers never had a way to set these, so listings
-- always fell back to the app's hardcoded placeholder values.
alter table public.listings add column if not exists weight text not null default '';
alter table public.listings add column if not exists origin text not null default '';
alter table public.listings add column if not exists grade text not null default '';
alter table public.listings add column if not exists packaging text not null default '';
