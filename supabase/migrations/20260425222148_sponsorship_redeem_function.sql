-- Sponsorship: Atomic redemption RPC
-- The Flutter app calls this from anonymous sessions to claim a code.
-- security definer + grant to anon means the function runs with elevated
-- rights but the caller never gets direct table access.

create or replace function public.redeem_access_code(
  p_code text,
  p_device_id text
)
returns table (
  success boolean,
  message text,
  expires_at timestamptz,
  organization_name text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_code_row public.access_codes%rowtype;
  v_org_row public.organizations%rowtype;
  v_normalised text;
  v_effective_expiry timestamptz;
begin
  v_normalised := upper(regexp_replace(coalesce(p_code, ''), '\s+', '', 'g'));

  if v_normalised = '' or coalesce(p_device_id, '') = '' then
    return query select false, 'Code and device id are required'::text, null::timestamptz, null::text;
    return;
  end if;

  select * into v_code_row
  from public.access_codes
  where upper(code) = v_normalised
  for update;

  if not found then
    return query select false, 'Invalid code'::text, null::timestamptz, null::text;
    return;
  end if;

  if not v_code_row.is_active then
    return query select false, 'This code has been deactivated'::text, null::timestamptz, null::text;
    return;
  end if;

  select * into v_org_row from public.organizations where id = v_code_row.organization_id;

  if not v_org_row.is_active then
    return query select false, 'Sponsor is no longer active'::text, null::timestamptz, null::text;
    return;
  end if;

  v_effective_expiry := coalesce(
    v_code_row.expires_at,
    case
      when v_org_row.contract_ends_on is not null
        then (v_org_row.contract_ends_on + interval '1 day')::timestamptz
      else null
    end
  );

  if v_effective_expiry is not null and v_effective_expiry < now() then
    return query select false, 'This code has expired'::text, null::timestamptz, null::text;
    return;
  end if;

  if v_code_row.redeemed_at is not null then
    if v_code_row.redeemed_by_device_id = p_device_id then
      return query select true,
        'Code already active on this device'::text,
        v_effective_expiry,
        v_org_row.name;
      return;
    else
      return query select false,
        'This code has already been redeemed on another device'::text,
        null::timestamptz,
        null::text;
      return;
    end if;
  end if;

  update public.access_codes
  set redeemed_at = now(),
      redeemed_by_device_id = p_device_id
  where id = v_code_row.id;

  return query select true,
    'Code redeemed successfully'::text,
    v_effective_expiry,
    v_org_row.name;
end;
$$;

revoke all on function public.redeem_access_code(text, text) from public;
grant execute on function public.redeem_access_code(text, text) to anon, authenticated;

-- Helper: validate a previously-redeemed code (called periodically by app)
create or replace function public.validate_access_code(
  p_code text,
  p_device_id text
)
returns table (
  is_valid boolean,
  expires_at timestamptz,
  organization_name text,
  reason text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_code_row public.access_codes%rowtype;
  v_org_row public.organizations%rowtype;
  v_normalised text;
  v_effective_expiry timestamptz;
begin
  v_normalised := upper(regexp_replace(coalesce(p_code, ''), '\s+', '', 'g'));

  select * into v_code_row
  from public.access_codes
  where upper(code) = v_normalised;

  if not found then
    return query select false, null::timestamptz, null::text, 'invalid'::text;
    return;
  end if;

  if not v_code_row.is_active then
    return query select false, null::timestamptz, null::text, 'deactivated'::text;
    return;
  end if;

  if v_code_row.redeemed_by_device_id is distinct from p_device_id then
    return query select false, null::timestamptz, null::text, 'wrong_device'::text;
    return;
  end if;

  select * into v_org_row from public.organizations where id = v_code_row.organization_id;

  if not v_org_row.is_active then
    return query select false, null::timestamptz, null::text, 'sponsor_inactive'::text;
    return;
  end if;

  v_effective_expiry := coalesce(
    v_code_row.expires_at,
    case
      when v_org_row.contract_ends_on is not null
        then (v_org_row.contract_ends_on + interval '1 day')::timestamptz
      else null
    end
  );

  if v_effective_expiry is not null and v_effective_expiry < now() then
    return query select false, v_effective_expiry, v_org_row.name, 'expired'::text;
    return;
  end if;

  return query select true, v_effective_expiry, v_org_row.name, 'ok'::text;
end;
$$;

revoke all on function public.validate_access_code(text, text) from public;
grant execute on function public.validate_access_code(text, text) to anon, authenticated;

comment on function public.redeem_access_code(text, text) is
  'Atomically claim an access code for a device. Anonymous-friendly.';
comment on function public.validate_access_code(text, text) is
  'Re-check whether a redeemed code is still valid for a device.';
