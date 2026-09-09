-- Phase 15.1/15.2: Order model with an escrow status state machine, plus a
-- mock "hold funds in escrow" payment step (no real Stripe/Bakong gateway).
--
-- Table is `escrow_orders`, not `orders` — the live DB already has a legacy
-- `orders` table from the original `supabase/migrations/*.sql` seed that
-- this backend does not own (see the Phase 9/10 migration notes); reusing
-- that name would collide with it.

create table if not exists public.escrow_orders (
  id text primary key,
  buyer_id text not null,
  seller_id text not null,
  listing_id text not null,
  product_name text not null,
  unit_price double precision not null,
  quantity integer not null,
  total_amount double precision not null,
  shipping_name text not null default '',
  shipping_address text not null default '',
  shipping_phone text not null default '',
  status text not null default 'pending_payment',
  payment_method text,
  payment_reference text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  paid_at timestamptz,
  released_at timestamptz,
  cancelled_at timestamptz
);

create index if not exists ix_escrow_orders_buyer_id on public.escrow_orders (buyer_id);
create index if not exists ix_escrow_orders_seller_id on public.escrow_orders (seller_id);
create index if not exists ix_escrow_orders_listing_id on public.escrow_orders (listing_id);
