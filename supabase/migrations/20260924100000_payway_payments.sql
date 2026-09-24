-- ABA PayWay transactions. One row per KHQR payment; it covers every
-- escrow order from one checkout, or one co-buy join.

create table if not exists public.payway_payments (
  tran_id text primary key,
  buyer_id text not null,
  order_ids jsonb not null default '[]'::jsonb,
  co_buy_participant_id text,
  amount double precision not null,
  currency text not null default 'USD',
  payment_option text not null default 'khqr',
  status text not null default 'pending',
  apv text,
  expires_at timestamptz not null,
  created_at timestamptz not null default now(),
  paid_at timestamptz
);

create index if not exists payway_payments_buyer_id_idx
  on public.payway_payments (buyer_id);
create index if not exists payway_payments_co_buy_participant_id_idx
  on public.payway_payments (co_buy_participant_id);
