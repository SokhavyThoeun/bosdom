alter table public.co_buy_deal_pools add column if not exists category text not null default '';
alter table public.co_buy_deal_pools add column if not exists weight text not null default '';
alter table public.co_buy_deal_pools add column if not exists origin text not null default '';
alter table public.co_buy_deal_pools add column if not exists grade text not null default '';
alter table public.co_buy_deal_pools add column if not exists packaging text not null default '';
