-- Buyer delivery address book (checkout > Address Book), previously kept only
-- on-device, so it was lost on reinstall and shared across accounts.

create table if not exists public.buyer_addresses (
  id text primary key,
  user_id text not null,
  label text not null default '',
  house_number text not null default '',
  sangkat text not null default '',
  province text not null default '',
  phone text not null default '',
  landmark text,
  district text,
  sangkat_name text,
  is_default boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists buyer_addresses_user_id_idx
  on public.buyer_addresses (user_id, created_at);
