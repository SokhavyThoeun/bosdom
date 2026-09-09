-- Phase 15.5: refund/release resolution logic for disputes.
--
-- A dispute settles by either releasing held funds to the seller or
-- refunding the buyer; the order needs a refunded_at timestamp to mirror
-- its existing paid_at/released_at/cancelled_at columns.

alter table public.escrow_orders
  add column if not exists refunded_at timestamptz;

alter table public.disputes
  add column if not exists resolution text,
  add column if not exists resolved_at timestamptz;
