-- The 20260909210000 migration's `create table if not exists public.listings`
-- included `sizes`/`colors` columns, but the live table already existed at
-- that point (created ad hoc pre-Alembic), so `create table if not exists`
-- no-op'd and never actually added them. Backfill directly with `alter table`.
alter table public.listings add column if not exists sizes jsonb not null default '[]'::jsonb;
alter table public.listings add column if not exists colors jsonb not null default '[]'::jsonb;
