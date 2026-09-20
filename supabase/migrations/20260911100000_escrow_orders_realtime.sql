-- Seller order list live-updates (16.7): let the Flutter app subscribe
-- directly to new/changed escrow orders via Supabase Realtime, the same
-- pattern used for chat messages (20260909240000_chat_conversations_messages.sql)
-- so a seller doesn't have to pull-to-refresh to see an order a buyer just
-- placed.

alter table public.escrow_orders enable row level security;

drop policy if exists "Participants can view their orders" on public.escrow_orders;
create policy "Participants can view their orders" on public.escrow_orders
  for select using (auth.uid()::text = buyer_id or auth.uid()::text = seller_id);

alter publication supabase_realtime add table public.escrow_orders;
