-- Phase 14: Chat & Policy. Real conversations/messages (replacing the
-- previous in-memory mock chat backend), a per-user chat ToS acceptance
-- flag, and off-platform-flag-driven send restriction, plus Realtime
-- wiring so the app can subscribe to live message inserts.

create table if not exists public.conversations (
  id text primary key,
  buyer_id text not null,
  seller_id text not null,
  listing_id text,
  buyer_last_read_at timestamptz,
  seller_last_read_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists ix_conversations_buyer_id on public.conversations (buyer_id);
create index if not exists ix_conversations_seller_id on public.conversations (seller_id);

create table if not exists public.messages (
  id text primary key,
  conversation_id text not null,
  sender_id text not null,
  text text not null,
  flagged boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists ix_messages_conversation_id on public.messages (conversation_id);
create index if not exists ix_messages_sender_id on public.messages (sender_id);

alter table public.profiles
  add column if not exists chat_tos_accepted_at timestamptz,
  add column if not exists chat_flag_count integer not null default 0,
  add column if not exists chat_restricted_until timestamptz;

-- RLS: only the two participants of a conversation can read it, or its
-- messages. The backend itself connects as the `postgres` role and bypasses
-- RLS for writes; these policies govern the Supabase Realtime subscription
-- the Flutter app will read directly (Phase 16).
alter table public.conversations enable row level security;
alter table public.messages enable row level security;

drop policy if exists "Participants can view their conversations" on public.conversations;
create policy "Participants can view their conversations" on public.conversations
  for select using (auth.uid()::text = buyer_id or auth.uid()::text = seller_id);

drop policy if exists "Participants can view their messages" on public.messages;
create policy "Participants can view their messages" on public.messages
  for select using (
    exists (
      select 1 from public.conversations c
      where c.id = messages.conversation_id
        and (auth.uid()::text = c.buyer_id or auth.uid()::text = c.seller_id)
    )
  );

alter publication supabase_realtime add table public.conversations;
alter publication supabase_realtime add table public.messages;
