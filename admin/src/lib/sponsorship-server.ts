import { supabaseAdmin } from '@/lib/supabase'
import { generateAccessCode } from './sponsorship'

/**
 * Issue a fresh access code linked to a recipient. The code is unique within
 * the access_codes table; we retry on the (vanishingly unlikely) collision.
 */
export async function issueCodeForRecipient(opts: {
  recipientId: string
  organizationId: string
  prefix?: string
  expiresAt?: string | null
  batchLabel?: string | null
  batchId?: string | null
}): Promise<{ id: string; code: string }> {
  const prefix = (opts.prefix || 'BTS').toUpperCase().slice(0, 8)
  let lastError: unknown = null

  for (let attempt = 0; attempt < 6; attempt++) {
    const code = generateAccessCode(prefix)
    const { data, error } = await supabaseAdmin
      .from('access_codes')
      .insert({
        code,
        organization_id: opts.organizationId,
        recipient_id: opts.recipientId,
        batch_id: opts.batchId,
        batch_label: opts.batchLabel,
        expires_at: opts.expiresAt,
        is_active: true,
      })
      .select('id, code')
      .single()

    if (!error && data) return data
    if (error && error.code !== '23505') {
      throw error
    }
    lastError = error
  }
  throw lastError instanceof Error ? lastError : new Error('Failed to allocate unique code')
}

/**
 * Revoke any currently-active codes for a recipient and issue a new one.
 * Used by the "reissue" flow.
 */
export async function reissueCodeForRecipient(opts: {
  recipientId: string
  organizationId: string
  prefix?: string
  expiresAt?: string | null
}): Promise<{ id: string; code: string }> {
  await supabaseAdmin
    .from('access_codes')
    .update({ is_active: false })
    .eq('recipient_id', opts.recipientId)
    .eq('is_active', true)
    .is('redeemed_at', null)

  const issued = await issueCodeForRecipient({
    recipientId: opts.recipientId,
    organizationId: opts.organizationId,
    prefix: opts.prefix,
    expiresAt: opts.expiresAt,
  })

  await supabaseAdmin
    .from('recipients')
    .update({
      reissue_count: (await getReissueCount(opts.recipientId)) + 1,
      status: 'invited',
      redeemed_at: null,
      redeemed_by_device_id: null,
      invited_at: new Date().toISOString(),
    })
    .eq('id', opts.recipientId)

  return issued
}

async function getReissueCount(recipientId: string): Promise<number> {
  const { data } = await supabaseAdmin
    .from('recipients')
    .select('reissue_count')
    .eq('id', recipientId)
    .single()
  return data?.reissue_count ?? 0
}

/** Get the currently-active code for a recipient, if any. */
export async function getActiveCodeForRecipient(recipientId: string): Promise<string | null> {
  const { data } = await supabaseAdmin
    .from('access_codes')
    .select('code')
    .eq('recipient_id', recipientId)
    .eq('is_active', true)
    .order('created_at', { ascending: false })
    .limit(1)
    .maybeSingle()
  return data?.code ?? null
}
