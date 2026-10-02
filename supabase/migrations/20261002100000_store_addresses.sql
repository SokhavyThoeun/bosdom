-- Seller store address book (Profile > Store Addresses), previously kept only
-- on-device. The first entry is seeded by the backend from shops.location.

create table if not exists public.store_addresses (
  id text primary key,
  seller_id text not null,
  label text not null default '',
  store_name text not null default '',
  business_type text not null default '',
  full_address text not null default '',
  district text not null default '',
  province text not null default '',
  phone text not null default '',
  email text not null default '',
  operating_hours text not null default '',
  is_default boolean not null default false,
  deleted boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists store_addresses_seller_id_idx
  on public.store_addresses (seller_id, created_at);
