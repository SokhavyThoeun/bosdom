-- Phase 15.3: QR generation + QR scan confirm-delivery endpoint.
--
-- Random code embedded in the QR the seller shows at handoff; the buyer
-- scans it to confirm delivery, which is what actually releases escrow.

alter table public.escrow_orders
  add column if not exists delivery_confirmation_code text;
