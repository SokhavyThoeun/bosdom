-- Shipping paid by the buyer is now recorded per order and passed on to the
-- seller on release, and paid co-buy joins get a real escrow order so they
-- go through the normal ship -> deliver -> release -> payout flow.

alter table public.escrow_orders
  add column if not exists shipping_fee double precision not null default 0,
  add column if not exists co_buy_participant_id text;

create index if not exists escrow_orders_co_buy_participant_id_idx
  on public.escrow_orders (co_buy_participant_id);

alter table public.payway_payments
  add column if not exists shipping_fee double precision not null default 0;
