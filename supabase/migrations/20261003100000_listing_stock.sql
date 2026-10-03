-- Live listing stock: paying for an order takes its units off the listing's
-- stock_qty, and a refund before it ships puts them back. This flag records
-- which orders took stock (older paid orders never did).

alter table public.escrow_orders
  add column if not exists stock_taken boolean not null default false;
