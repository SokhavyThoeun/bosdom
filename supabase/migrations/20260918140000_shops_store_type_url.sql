-- "Type of Store" and "Online Store URL" are collected in the Business Info
-- step but were never persisted — silently dropped before reaching the
-- backend, so admin review never saw them.
alter table public.shops add column if not exists store_type text not null default '';
alter table public.shops add column if not exists store_url text not null default '';
