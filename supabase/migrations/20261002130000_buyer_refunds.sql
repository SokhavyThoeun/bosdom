-- Buyer refunds: each order records its share of the 2% escrow fee, and a
-- refund records the amount owed back (fee kept only when the buyer is at
-- fault) and when the admin sent it.

alter table public.escrow_orders
  add column if not exists escrow_fee double precision not null default 0,
  add column if not exists refund_amount double precision,
  add column if not exists refund_sent_at timestamptz;

alter table public.payway_payments
  add column if not exists refund_sent_at timestamptz;
