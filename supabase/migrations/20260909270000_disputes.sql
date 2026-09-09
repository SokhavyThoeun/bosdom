-- Phase 15.4: dispute model + video evidence upload endpoint, with a
-- time-limited window (48h, enforced in the app, not in SQL) for evidence
-- submission after a dispute is opened. Resolving a dispute (release vs.
-- refund) is Phase 15.5, not part of this migration.

create table if not exists public.disputes (
  id text primary key,
  order_id text not null,
  raised_by text not null,
  reason text not null,
  note text not null default '',
  status text not null default 'evidence_window',
  evidence_deadline timestamptz not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists ix_disputes_order_id on public.disputes (order_id);
create index if not exists ix_disputes_raised_by on public.disputes (raised_by);

create table if not exists public.dispute_evidence (
  id text primary key,
  dispute_id text not null,
  file_url text not null,
  uploaded_at timestamptz not null default now()
);

create index if not exists ix_dispute_evidence_dispute_id on public.dispute_evidence (dispute_id);
