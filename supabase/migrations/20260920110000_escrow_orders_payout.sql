-- Seller withdraws released earnings to a bank account. Released orders with
-- payout_requested_at set are on their way (arrive at payout_eta_at, 1-3h
-- later); the seller's balance is released orders with it still null.

alter table public.escrow_orders
  add column if not exists payout_requested_at timestamptz,
  add column if not exists payout_eta_at timestamptz,
  add column if not exists payout_bank_name text,
  add column if not exists payout_account_holder text,
  add column if not exists payout_account_number text;
