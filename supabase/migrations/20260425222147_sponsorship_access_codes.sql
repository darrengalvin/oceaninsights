-- Sponsorship: Access Codes
-- Individual codes generated for an organisation. Each code unlocks premium
-- on one device (or one user once auth is added).

create table if not exists public.access_codes (
  id uuid primary key default gen_random_uuid(),
  code text not null,
  organization_id uuid not null references public.organizations(id) on delete cascade,
  batch_id uuid,
  batch_label text,

  redeemed_at timestamptz,
  redeemed_by_device_id text,
  redeemed_by_user_id uuid references auth.users(id) on delete set null,

  expires_at timestamptz,
  is_active boolean not null default true,

  created_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null,

  constraint access_codes_code_unique unique (code)
);

create index if not exists access_codes_organization_id_idx on public.access_codes(organization_id);
create index if not exists access_codes_batch_id_idx on public.access_codes(batch_id);
create index if not exists access_codes_redeemed_idx on public.access_codes(redeemed_at)
  where redeemed_at is not null;
create index if not exists access_codes_unredeemed_idx on public.access_codes(organization_id)
  where redeemed_at is null and is_active = true;

alter table public.access_codes enable row level security;

comment on table public.access_codes is
  'Individual access codes belonging to an organisation. Redeemed via redeem_access_code() RPC.';
comment on column public.access_codes.code is
  'Human-friendly redemption code, e.g. BTS-A4F2-9KX7.';
comment on column public.access_codes.batch_id is
  'Groups codes generated together so admins can manage them as a batch.';
