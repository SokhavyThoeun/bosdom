-- Per-account notification feed, written by the backend whenever something
-- happens to a user (new chat message, order status change, co-buy news...).

create table if not exists public.user_notifications (
  id text primary key,
  user_id text not null,
  category text not null,
  title text not null,
  body text not null default '',
  target_route text,
  target_params jsonb not null default '{}'::jsonb,
  read boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists user_notifications_user_id_idx
  on public.user_notifications (user_id, created_at desc);
