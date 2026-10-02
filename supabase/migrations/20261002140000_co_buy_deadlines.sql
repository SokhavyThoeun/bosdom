-- Co-buy deals get a real deadline and lifecycle: open -> funded (target
-- reached, seller may ship) or expired (time ran out, everyone refunded).

alter table public.co_buy_deal_pools
  add column if not exists ends_at timestamptz,
  add column if not exists status text not null default 'open';
