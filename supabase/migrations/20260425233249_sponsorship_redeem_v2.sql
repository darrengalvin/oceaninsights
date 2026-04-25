-- Sponsorship V2: redemption RPC update.
--
-- New behaviour:
--   * Looks up code via access_codes table (codes can either be standalone or
--     linked to a recipient).
--   * If linked to a recipient: marks the recipient as redeemed.
--   * Honours organization.billing_mode = 'prepaid' by blocking when
--     seats_redeemed >= seats_purchased.
--   * Increments organization.seats_redeemed on success.
--   * Always writes an entry to redemption_events for billing/audit.
--
-- The function signature is unchanged so the existing Flutter app keeps
-- working without a release.

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
  v_code public.access_codes%rowtype;
  v_org public.organizations%rowtype;
  v_recipient public.recipients%rowtype;
  v_normalised text;
  v_effective_expiry timestamptz;
  v_failure text;
begin
  v_normalised := upper(regexp_replace(coalesce(p_code, ''), '\s+', '', 'g'));

  if v_normalised = '' or coalesce(p_device_id, '') = '' then
    insert into public.redemption_events
      (code_text, device_id, succeeded, failure_reason)
      values (v_normalised, p_device_id, false, 'missing_input');
    return query select false, 'Code and device id are required'::text, null::timestamptz, null::text;
    return;
  end if;

  select * into v_code
  from public.access_codes
  where upper(code) = v_normalised
  for update;

  if not found then
    insert into public.redemption_events
      (code_text, device_id, succeeded, failure_reason)
      values (v_normalised, p_device_id, false, 'invalid');
    return query select false, 'Invalid code'::text, null::timestamptz, null::text;
    return;
  end if;

  if not v_code.is_active then
    insert into public.redemption_events
      (code_text, access_code_id, organization_id, recipient_id, device_id, succeeded, failure_reason)
      values (v_normalised, v_code.id, v_code.organization_id, v_code.recipient_id, p_device_id, false, 'deactivated');
    return query select false, 'This code has been deactivated'::text, null::timestamptz, null::text;
    return;
  end if;

  select * into v_org from public.organizations where id = v_code.organization_id;
  if not v_org.is_active then
    insert into public.redemption_events
      (code_text, access_code_id, organization_id, recipient_id, device_id, succeeded, failure_reason)
      values (v_normalised, v_code.id, v_org.id, v_code.recipient_id, p_device_id, false, 'sponsor_inactive');
    return query select false, 'Sponsor is no longer active'::text, null::timestamptz, null::text;
    return;
  end if;

  v_effective_expiry := coalesce(
    v_code.expires_at,
    case
      when v_org.contract_ends_on is not null
        then (v_org.contract_ends_on + interval '1 day')::timestamptz
      else null
    end
  );

  if v_effective_expiry is not null and v_effective_expiry < now() then
    insert into public.redemption_events
      (code_text, access_code_id, organization_id, recipient_id, device_id, succeeded, failure_reason)
      values (v_normalised, v_code.id, v_org.id, v_code.recipient_id, p_device_id, false, 'expired');
    return query select false, 'This code has expired'::text, null::timestamptz, null::text;
    return;
  end if;

  -- Already redeemed? Allow re-redemption from the same device (idempotent),
  -- block from a different device (anti-leak).
  if v_code.redeemed_at is not null then
    if v_code.redeemed_by_device_id = p_device_id then
      insert into public.redemption_events
        (code_text, access_code_id, organization_id, recipient_id, device_id, succeeded, failure_reason)
        values (v_normalised, v_code.id, v_org.id, v_code.recipient_id, p_device_id, true, 'reactivated_same_device');
      return query select true,
        'Code already active on this device'::text,
        v_effective_expiry,
        v_org.name;
      return;
    else
      insert into public.redemption_events
        (code_text, access_code_id, organization_id, recipient_id, device_id, succeeded, failure_reason)
        values (v_normalised, v_code.id, v_org.id, v_code.recipient_id, p_device_id, false, 'wrong_device');
      return query select false,
        'This code has already been redeemed on another device. Ask your welfare officer to reissue.'::text,
        null::timestamptz,
        null::text;
      return;
    end if;
  end if;

  -- Prepaid balance gate
  if v_org.billing_mode = 'prepaid'
     and v_org.seats_purchased > 0
     and v_org.seats_redeemed >= v_org.seats_purchased then
    insert into public.redemption_events
      (code_text, access_code_id, organization_id, recipient_id, device_id, succeeded, failure_reason)
      values (v_normalised, v_code.id, v_org.id, v_code.recipient_id, p_device_id, false, 'prepaid_exhausted');
    return query select false,
      'Your sponsor has used all their prepaid seats. Contact them to top up.'::text,
      null::timestamptz,
      null::text;
    return;
  end if;

  -- Successful redemption: update code, recipient, org counter, and event log.
  update public.access_codes
  set redeemed_at = now(),
      redeemed_by_device_id = p_device_id
  where id = v_code.id;

  if v_code.recipient_id is not null then
    update public.recipients
    set status = 'redeemed',
        redeemed_at = now(),
        redeemed_by_device_id = p_device_id
    where id = v_code.recipient_id;
  end if;

  update public.organizations
  set seats_redeemed = seats_redeemed + 1
  where id = v_org.id;

  insert into public.redemption_events
    (code_text, access_code_id, organization_id, recipient_id, device_id, succeeded)
    values (v_normalised, v_code.id, v_org.id, v_code.recipient_id, p_device_id, true);

  return query select true,
    'Code redeemed successfully'::text,
    v_effective_expiry,
    v_org.name;
end;
$$;

grant execute on function public.redeem_access_code(text, text) to anon, authenticated;

comment on function public.redeem_access_code(text, text) is
  'V2: recipient-aware, billing-aware, audit-logged redemption. Anonymous-friendly.';
