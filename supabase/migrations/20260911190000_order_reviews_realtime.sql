-- Let the order detail screen (buyer's own + seller's, both via
-- orderByIdProvider) pick up a submitted review live instead of only on a
-- fresh fetch — same Realtime pattern as escrow_orders
-- (20260911100000_escrow_orders_realtime.sql). order_reviews has no
-- seller_id column, so the seller's visibility is derived by joining back
-- to the order it belongs to.

alter table public.order_reviews enable row level security;

drop policy if exists "Order participants can view reviews" on public.order_reviews;
create policy "Order participants can view reviews" on public.order_reviews
  for select using (
    auth.uid()::text = buyer_id
    or exists (
      select 1 from public.escrow_orders o
      where o.id = order_reviews.order_id and o.seller_id = auth.uid()::text
    )
  );

alter publication supabase_realtime add table public.order_reviews;
