export type OrganizationType = 'military' | 'school' | 'charity' | 'corporate' | 'other'

export type BillingMode = 'prepaid' | 'postpaid_quarterly'

export interface Organization {
  id: string
  name: string
  slug: string
  type: OrganizationType
  contact_name: string | null
  contact_email: string | null
  contact_phone: string | null
  notes: string | null
  contract_starts_on: string | null
  contract_ends_on: string | null
  seats_purchased: number
  seats_redeemed: number
  billing_mode: BillingMode
  billing_batch_size: number
  allow_reissue: boolean
  max_reissues_per_recipient: number
  privacy_promise_enabled: boolean
  is_active: boolean
  created_at: string
  updated_at: string
  created_by: string | null
}

export type RecipientStatus = 'invited' | 'redeemed' | 'revoked' | 'expired'

export interface Recipient {
  id: string
  organization_id: string
  unit_id: string | null
  identifier: string
  display_name: string | null
  email: string | null
  pseudonym: string | null
  status: RecipientStatus
  invited_at: string | null
  email_sent_at: string | null
  email_opened_at: string | null
  redeemed_at: string | null
  redeemed_by_device_id: string | null
  reissue_count: number
  notes: string | null
  created_at: string
  updated_at: string
  active_code?: string | null
}

export interface RedemptionEvent {
  id: string
  organization_id: string | null
  recipient_id: string | null
  access_code_id: string | null
  code_text: string | null
  device_id: string | null
  ip_address: string | null
  user_agent: string | null
  succeeded: boolean
  failure_reason: string | null
  occurred_at: string
}

export const RECIPIENT_STATUS_LABELS: Record<RecipientStatus, string> = {
  invited: 'Invited',
  redeemed: 'Redeemed',
  revoked: 'Revoked',
  expired: 'Expired',
}

export const RECIPIENT_STATUS_COLORS: Record<RecipientStatus, string> = {
  invited: 'bg-blue-50 text-blue-700 border-blue-200',
  redeemed: 'bg-emerald-50 text-emerald-700 border-emerald-200',
  revoked: 'bg-gray-100 text-gray-600 border-gray-200',
  expired: 'bg-amber-50 text-amber-700 border-amber-200',
}

export interface OrganizationWithStats extends Organization {
  codes_total: number
  codes_redeemed: number
  codes_active_unredeemed: number
  recipients_total: number
  recipients_redeemed: number
}

export interface AccessCode {
  id: string
  code: string
  organization_id: string
  batch_id: string | null
  batch_label: string | null
  redeemed_at: string | null
  redeemed_by_device_id: string | null
  redeemed_by_user_id: string | null
  expires_at: string | null
  is_active: boolean
  created_at: string
  created_by: string | null
}

export const ORG_TYPE_LABELS: Record<OrganizationType, string> = {
  military: 'Military',
  school: 'School',
  charity: 'Charity',
  corporate: 'Corporate',
  other: 'Other',
}

export const ORG_TYPE_COLORS: Record<OrganizationType, string> = {
  military: 'bg-emerald-100 text-emerald-700 border-emerald-200',
  school: 'bg-blue-100 text-blue-700 border-blue-200',
  charity: 'bg-purple-100 text-purple-700 border-purple-200',
  corporate: 'bg-amber-100 text-amber-700 border-amber-200',
  other: 'bg-slate-100 text-slate-700 border-slate-200',
}

export function slugify(input: string): string {
  return input
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 60)
}

const CODE_ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789' // skip 0/O/1/I

export function generateAccessCode(prefix = 'BTS'): string {
  const block = (n: number) => {
    let s = ''
    const bytes = new Uint8Array(n)
    if (typeof crypto !== 'undefined' && crypto.getRandomValues) {
      crypto.getRandomValues(bytes)
    } else {
      for (let i = 0; i < n; i++) bytes[i] = Math.floor(Math.random() * 256)
    }
    for (let i = 0; i < n; i++) s += CODE_ALPHABET[bytes[i] % CODE_ALPHABET.length]
    return s
  }
  return `${prefix}-${block(4)}-${block(4)}`
}
