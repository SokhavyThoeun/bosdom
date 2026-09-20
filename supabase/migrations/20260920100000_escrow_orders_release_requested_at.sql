-- Sellers can ask the admin to release held escrow funds early; the admin
-- panel's "Payout Requests" tab lists orders where this is set.

alter table public.escrow_orders
  add column if not exists release_requested_at timestamptz;
