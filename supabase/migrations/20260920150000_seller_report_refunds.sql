-- Lets an admin cancel an order over a courier problem and refund the buyer,
-- either right away or after a short hold (refund_due_at).

alter table public.seller_reports
  add column if not exists refund_due_at timestamptz,
  add column if not exists resolution text;
