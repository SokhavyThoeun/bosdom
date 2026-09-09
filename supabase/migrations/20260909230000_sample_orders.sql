-- Phase 12: Sample Gate. One sample order per buyer, then a 3-day cooldown
-- before they're eligible to order another (enforced in the backend, not a
-- DB constraint, since it's a rolling window off `created_at` rather than a
-- fixed cap).

create table if not exists public.sample_orders (
  id text primary key,
  buyer_id text not null,
  listing_id text not null,
  seller_id text not null,
  product_name text not null,
  price double precision not null,
  status text not null default 'processing',
  created_at timestamptz not null default now()
);

create index if not exists ix_sample_orders_buyer_id on public.sample_orders (buyer_id);
create index if not exists ix_sample_orders_listing_id on public.sample_orders (listing_id);
create index if not exists ix_sample_orders_seller_id on public.sample_orders (seller_id);
