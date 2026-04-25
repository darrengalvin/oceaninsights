-- Sponsorship: Organizations
-- Tracks military units, schools, charities, corporates etc. that purchase
-- bulk access to Below the Surface for their members.

create extension if not exists "pgcrypto";

create table if not exists public.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null,
  type text not null check (type in ('military', 'school', 'charity', 'corporate', 'other')),

  contact_name text,
  contact_email text,
  contact_phone text,
  notes text,

  contract_starts_on date,
  contract_ends_on date,
  seats_purchased integer not null default 0 check (seats_purchased >= 0),

  is_active boolean not null default true,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null,

  constraint organizations_slug_unique unique (slug)
);

create index if not exists organizations_type_idx on public.organizations(type);
create index if not exists organizations_is_active_idx on public.organizations(is_active);

-- updated_at trigger
create or replace function public.tg_set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists organizations_set_updated_at on public.organizations;
create trigger organizations_set_updated_at
  before update on public.organizations
  for each row execute function public.tg_set_updated_at();

-- Lock down completely. Admin panel uses service_role which bypasses RLS.
-- Anon/authenticated app users have no business reading this table directly.
alter table public.organizations enable row level security;

comment on table public.organizations is
  'Sponsoring organisations (military units, schools, charities) that purchase bulk access codes.';
