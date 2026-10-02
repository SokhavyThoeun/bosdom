-- Each seller ships their own parcel, so a multi-seller checkout's shipping
-- is priced per seller; this records each order's part of it.

alter table public.payway_payments
  add column if not exists shipping_shares json not null default '{}'::json;
