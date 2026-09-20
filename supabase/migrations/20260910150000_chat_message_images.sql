-- Phase 16.8: Chat image messages. Photos attached in chat were previously
-- local-only (picked from the device and never uploaded), so the two sides
-- of a conversation each saw their own device's photo instead of the one
-- actually sent. Adds a nullable image_url alongside text so a message can
-- carry either (or, in principle, both).

alter table public.messages
  alter column text drop not null,
  add column if not exists image_url text;
