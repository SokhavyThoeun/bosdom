-- Samples are now bought as paid escrow orders (one unit at the listing's
-- full sample price) instead of free `sample_orders` requests.

alter table public.escrow_orders
  add column if not exists is_sample boolean not null default false;
