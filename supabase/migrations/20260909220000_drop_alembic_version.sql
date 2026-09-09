-- Alembic was removed in favor of the Supabase CLI's own migration system
-- (see CHECKPOINT.md, Phase 10 notes). alembic_version was Alembic's internal
-- bookkeeping table and is no longer read or written by anything.

drop table if exists public.alembic_version;
