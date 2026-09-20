-- Co-buy join-to-pay escrow: joining a pool now holds the buyer's payment
-- (mirroring escrow_orders' pending_payment -> held -> released) instead of
-- reserving a spot for free. Leaving mid-hold moves a participant to
-- leave_requested rather than deleting the row outright, so there's still a
-- record to refund once an admin flow exists to act on it.

alter table public.co_buy_deal_participants
  add column if not exists status text not null default 'pending_payment',
  add column if not exists payment_method text,
  add column if not exists payment_reference text,
  add column if not exists paid_at timestamptz,
  add column if not exists leave_requested_at timestamptz,
  add column if not exists released_at timestamptz,
  add column if not exists refunded_at timestamptz;
