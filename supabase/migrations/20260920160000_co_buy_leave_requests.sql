-- Co-buy leave requests: a paid participant can't just walk away. They ask
-- to leave with a reason, and an admin approves (refund) or rejects it.

alter table public.co_buy_deal_participants
  add column if not exists leave_reason text,
  add column if not exists leave_admin_note text,
  add column if not exists leave_resolved_at timestamptz;
