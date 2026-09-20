-- Seller-raised delivery reports (courier delay, lost parcel, ...). Unlike a
-- buyer dispute this never freezes funds; it just lets an admin know so they
-- can look into it and update the buyer.

create table if not exists public.seller_reports (
  id text primary key,
  order_id text not null,
  seller_id text not null,
  reason text not null,
  note text not null default '',
  photo_urls jsonb not null default '[]'::jsonb,
  status text not null default 'open',
  created_at timestamptz not null default now()
);

create index if not exists ix_seller_reports_order_id on public.seller_reports (order_id);
create index if not exists ix_seller_reports_seller_id on public.seller_reports (seller_id);
