-- Baseline for the tables the FastAPI backend's SQLAlchemy models own
-- (shops, listings, order_reports; `profiles` already exists from
-- 20260903000000_profiles.sql). These were previously created ad hoc by
-- SQLAlchemy directly against the live database — this migration is the
-- first time they're captured as SQL, so every statement is idempotent.
--
-- The live database also has legacy tables (user_profiles, products, orders,
-- categories, co_buy_pools, co_buy_participants, order_items) from the
-- original schema draft. Those are not owned by the backend and must not be
-- touched here.

create table if not exists public.shops (
  id text primary key,
  shop_name text not null default '',
  business_type text not null default '',
  year_established text not null default '',
  location text not null default '',
  phone text not null default '',
  email text not null default '',
  description text not null default '',
  logo_url text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.listings (
  id text primary key,
  seller_id text not null,
  product_name text not null,
  category text not null,
  price double precision not null,
  moq_qty integer not null,
  stock_qty integer not null,
  description text not null default '',
  sample_testing_enabled boolean not null default false,
  sample_price double precision,
  photo_urls jsonb not null default '[]'::jsonb,
  sizes jsonb not null default '[]'::jsonb,
  colors jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists ix_listings_seller_id on public.listings (seller_id);

create table if not exists public.order_reports (
  id text primary key,
  order_id text not null,
  reason text not null,
  note text not null default '',
  created_at timestamptz not null default now()
);

create index if not exists ix_order_reports_order_id on public.order_reports (order_id);
