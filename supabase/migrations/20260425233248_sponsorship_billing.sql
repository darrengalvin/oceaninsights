-- Sponsorship V2: billing configuration on the organization.
--
-- billing_mode controls whether redemptions are gated by a prepaid balance:
--   * 'prepaid'           - block redemptions when seats_redeemed >= seats_purchased
--   * 'postpaid_quarterly'- never block; we invoice based on the redemption_events log
--
-- billing_batch_size is purely a contract-side rounding unit shown on the
-- invoice ("billed in lots of 500"); not enforced by the schema.

alter table public.organizations
  add column if not exists billing_mode text not null default 'prepaid'
    check (billing_mode in ('prepaid', 'postpaid_quarterly')),
  add column if not exists billing_batch_size integer not null default 100
    check (billing_batch_size > 0),
  add column if not exists seats_redeemed integer not null default 0,
  add column if not exists allow_reissue boolean not null default true,
  add column if not exists max_reissues_per_recipient integer not null default 4
    check (max_reissues_per_recipient >= 0),
  add column if not exists privacy_promise_enabled boolean not null default true;

comment on column public.organizations.billing_mode is
  'Either prepaid (blocks redemptions over seats_purchased) or postpaid_quarterly (always allows; invoiced retrospectively).';
comment on column public.organizations.billing_batch_size is
  'Display unit on the contract / invoice (e.g. "billed in lots of 500"). Not technically enforced.';
comment on column public.organizations.seats_redeemed is
  'Cached count of successful redemptions tied to this organisation. Maintained by the redeem RPC.';
comment on column public.organizations.allow_reissue is
  'Whether welfare officers can revoke a recipient''s code and issue a new one.';
