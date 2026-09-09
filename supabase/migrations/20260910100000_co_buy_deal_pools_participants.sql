-- Phase 13/16.4: real Co-Buying backend (deferred at Phase 13, built now
-- while wiring the frontend to it end-to-end).
--
-- Tables are `co_buy_deal_pools`/`co_buy_deal_participants`, not
-- `co_buy_pools`/`co_buy_participants` — the live DB already has legacy
-- tables under those exact names from the original seed that this backend
-- does not own (see the Phase 9/10 migration notes); reusing those names
-- would collide with them.

create table if not exists public.co_buy_deal_pools (
  id text primary key,
  seller_id text not null,
  product_name text not null,
  description text not null default '',
  price double precision not null,
  original_price double precision not null,
  target_qty integer not null,
  unit_label text not null,
  per_unit_label text not null,
  min_order_qty integer not null,
  time_left text not null,
  auto_renew boolean not null default false,
  photo_urls jsonb not null default '[]'::jsonb,
  sizes jsonb not null default '[]'::jsonb,
  colors jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists ix_co_buy_deal_pools_seller_id on public.co_buy_deal_pools (seller_id);

create table if not exists public.co_buy_deal_participants (
  id text primary key,
  pool_id text not null,
  buyer_id text not null,
  quantity integer not null,
  size text,
  color_name text,
  color_hex text,
  joined_at timestamptz not null default now()
);

create index if not exists ix_co_buy_deal_participants_pool_id on public.co_buy_deal_participants (pool_id);
create index if not exists ix_co_buy_deal_participants_buyer_id on public.co_buy_deal_participants (buyer_id);
