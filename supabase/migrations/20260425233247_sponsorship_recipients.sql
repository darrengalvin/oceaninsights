-- Sponsorship V2: shift to a person-first data model.
-- We keep the existing organizations + access_codes tables (so the HMS Vanguard
-- pilot data isn't lost) and bolt on:
--   * units             - optional sub-grouping under an organisation
--   * recipients        - the actual people we're issuing access to
--   * redemption_events - audit log for billing + leak detection
-- Existing access_codes get an optional recipient_id link so they can be
-- migrated forward later if needed.

create table if not exists public.units (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  name text not null,
  description text,
  is_default boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists units_default_per_org_idx
  on public.units(organization_id) where is_default = true;
create index if not exists units_organization_id_idx on public.units(organization_id);

drop trigger if exists units_set_updated_at on public.units;
create trigger units_set_updated_at
  before update on public.units
  for each row execute function public.tg_set_updated_at();

alter table public.units enable row level security;

-- Recipient = a single person being invited. Identified by an opaque
-- identifier (service number, employee id, student id - chosen by the
-- sponsor) plus optionally an email address for delivery.
create table if not exists public.recipients (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  unit_id uuid references public.units(id) on delete set null,

  identifier text not null,            -- sponsor-side identifier (e.g. service number, anonymous id)
  display_name text,                   -- optional friendly name for sponsor's UI only
  email text,                          -- delivery address; optional in case the sponsor distributes manually
  pseudonym text,                      -- optional handle the user can choose later

  status text not null default 'invited' check (
    status in ('invited', 'redeemed', 'revoked', 'expired')
  ),

  invited_at timestamptz,
  email_sent_at timestamptz,
  email_opened_at timestamptz,         -- if we wire up tracking pixels later
  redeemed_at timestamptz,
  redeemed_by_device_id text,
  reissue_count integer not null default 0,
  notes text,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null,

  constraint recipients_identifier_per_org unique (organization_id, identifier)
);

create index if not exists recipients_organization_idx on public.recipients(organization_id);
create index if not exists recipients_unit_idx on public.recipients(unit_id);
create index if not exists recipients_status_idx on public.recipients(status);
create index if not exists recipients_email_idx on public.recipients(lower(email))
  where email is not null;

drop trigger if exists recipients_set_updated_at on public.recipients;
create trigger recipients_set_updated_at
  before update on public.recipients
  for each row execute function public.tg_set_updated_at();

alter table public.recipients enable row level security;

-- Link existing access_codes to a recipient (optional - for v1 codes generated
-- via the bulk generator, this stays NULL).
alter table public.access_codes
  add column if not exists recipient_id uuid references public.recipients(id) on delete set null;

create index if not exists access_codes_recipient_id_idx
  on public.access_codes(recipient_id) where recipient_id is not null;

-- Audit log of every redemption attempt (both successful and failed). Used for
-- billing reconciliation + leak detection.
create table if not exists public.redemption_events (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid references public.organizations(id) on delete set null,
  recipient_id uuid references public.recipients(id) on delete set null,
  access_code_id uuid references public.access_codes(id) on delete set null,
  code_text text,                      -- denormalised so events survive deletions

  device_id text,
  ip_address inet,
  user_agent text,
  succeeded boolean not null,
  failure_reason text,                 -- 'invalid', 'expired', 'wrong_device', 'sponsor_inactive', 'prepaid_exhausted', etc.

  occurred_at timestamptz not null default now()
);

create index if not exists redemption_events_org_idx on public.redemption_events(organization_id, occurred_at desc);
create index if not exists redemption_events_recipient_idx on public.redemption_events(recipient_id);
create index if not exists redemption_events_succeeded_idx on public.redemption_events(succeeded, occurred_at desc);
create index if not exists redemption_events_burst_idx on public.redemption_events(organization_id, occurred_at)
  where succeeded = true;

alter table public.redemption_events enable row level security;

comment on table public.units is
  'Optional sub-grouping of recipients under a sponsoring organisation (e.g. HMS Vanguard within MOD).';
comment on table public.recipients is
  'A single person invited by a sponsor. Identified by a sponsor-side identifier (e.g. service number).';
comment on table public.redemption_events is
  'Append-only audit log of redemption attempts. Source of truth for billing and leak detection.';
