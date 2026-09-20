-- Store photos for the seller's Business Info step (previously a mock
-- counter with no real upload or persistence).
alter table public.shops add column if not exists photo_urls jsonb not null default '[]'::jsonb;
