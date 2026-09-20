-- Buyer star rating + written review (+ optional photos) left on a
-- completed (`released`) order. One row per order — resubmitting a review
-- updates this row instead of inserting a second one (see
-- submit_order_review, routers/orders.py). Surfaced back on the order
-- detail screen for both the buyer and the seller via OrderOut.review.

create table if not exists public.order_reviews (
  id text primary key,
  order_id text not null unique,
  buyer_id text not null,
  rating integer not null,
  comment text not null default '',
  photo_urls jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists ix_order_reviews_order_id on public.order_reviews (order_id);
create index if not exists ix_order_reviews_buyer_id on public.order_reviews (buyer_id);
