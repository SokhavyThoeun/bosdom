-- Fund-release flow: buyer pays (held) -> seller ships (photo + tracking) ->
-- delivered (proof) -> buyer review timer -> auto-release (fee taken) or a
-- reported problem (timer freezes) -> admin case -> admin decides.

alter table public.escrow_orders
  add column if not exists shipped_at timestamptz,
  add column if not exists courier text,
  add column if not exists tracking_number text,
  add column if not exists shipping_photo_url text,
  add column if not exists delivered_at timestamptz,
  add column if not exists delivery_proof_url text,
  add column if not exists review_deadline_at timestamptz,
  add column if not exists review_remaining_seconds integer,
  add column if not exists platform_fee double precision,
  add column if not exists seller_amount double precision,
  add column if not exists auto_released boolean not null default false;

alter table public.disputes
  add column if not exists case_opened_at timestamptz,
  add column if not exists seller_response text,
  add column if not exists seller_responded_at timestamptz,
  add column if not exists courier_response text,
  add column if not exists courier_responded_at timestamptz,
  add column if not exists fault text;
