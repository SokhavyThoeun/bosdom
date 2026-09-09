-- Adds KYC document upload support (Phase 10.4) and a verification status
-- on profiles (Phase 10.1). Idempotent since these were already created
-- against the live database by the now-removed Alembic migration
-- e19311b268dc.

create table if not exists public.kyc_documents (
  id text primary key,
  profile_id text not null,
  doc_type text not null,
  file_url text not null,
  uploaded_at timestamptz not null default now()
);

create index if not exists ix_kyc_documents_profile_id on public.kyc_documents (profile_id);

alter table public.profiles
  add column if not exists verification_status text not null default 'unverified';
