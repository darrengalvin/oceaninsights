// Supabase Edge Function for Apple App Store Server Notifications
// Deploy: supabase functions deploy apple-webhook

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Apple sends POST requests with JWS (JSON Web Signature) payload
    const body = await req.json()
    
    console.log('📱 Received Apple notification')
    
    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    // Apple's notification structure (v2)
    // The signedPayload contains a JWS that needs to be decoded
    // For simplicity, we'll store the raw payload and extract key fields
    
    const signedPayload = body.signedPayload
    
    // Decode the JWS payload (base64url encoded, 3 parts separated by .)
    // We're extracting without full verification for simplicity
    // In production, you should verify the signature using Apple's public key
    let notificationData: any = {}
    
    if (signedPayload) {
      try {
        const parts = signedPayload.split('.')
        if (parts.length === 3) {
          // Decode the payload (second part)
          const payloadBase64 = parts[1]
          const payloadJson = atob(payloadBase64.replace(/-/g, '+').replace(/_/g, '/'))
          notificationData = JSON.parse(payloadJson)
        }
      } catch (decodeError) {
        console.error('Error decoding JWS:', decodeError)
        // Store raw payload anyway
        notificationData = { raw: signedPayload }
      }
    } else {
      // Fallback for different payload structure
      notificationData = body
    }

    // Extract notification details
    const notificationType = notificationData.notificationType || body.notificationType || 'UNKNOWN'
    const subtype = notificationData.subtype || body.subtype
    const notificationUUID = notificationData.notificationUUID || body.notificationUUID
    const environment = notificationData.environment || body.environment || 'Unknown'
    
    // Extract transaction info from nested data
    const transactionInfo = notificationData.data?.signedTransactionInfo
    let transactionData: any = {}
    
    if (transactionInfo) {
      try {
        const txParts = transactionInfo.split('.')
        if (txParts.length === 3) {
          const txPayload = atob(txParts[1].replace(/-/g, '+').replace(/_/g, '/'))
          transactionData = JSON.parse(txPayload)
        }
      } catch (e) {
        console.error('Error decoding transaction:', e)
      }
    }

    // Extract renewal info
    const renewalInfo = notificationData.data?.signedRenewalInfo
    let renewalData: any = {}
    
    if (renewalInfo) {
      try {
        const renewParts = renewalInfo.split('.')
        if (renewParts.length === 3) {
          const renewPayload = atob(renewParts[1].replace(/-/g, '+').replace(/_/g, '/'))
          renewalData = JSON.parse(renewPayload)
        }
      } catch (e) {
        console.error('Error decoding renewal info:', e)
      }
    }

    // Store the notification
    const { error: insertError } = await supabase
      .from('apple_notifications')
      .insert({
        notification_type: notificationType,
        subtype: subtype,
        notification_uuid: notificationUUID,
        original_transaction_id: transactionData.originalTransactionId,
        transaction_id: transactionData.transactionId,
        product_id: transactionData.productId,
        expires_date: transactionData.expiresDate 
          ? new Date(transactionData.expiresDate).toISOString()
          : null,
        auto_renew_status: renewalData.autoRenewStatus === 1,
        is_in_billing_retry: renewalData.isInBillingRetryPeriod === true,
        environment: environment,
        raw_payload: body,
        signed_date: notificationData.signedDate 
          ? new Date(notificationData.signedDate).toISOString()
          : null,
      })

    if (insertError) {
      console.error('Error storing notification:', insertError)
      // Still return 200 to Apple so they don't retry
    } else {
      console.log(`✅ Stored ${notificationType} notification for product: ${transactionData.productId || 'unknown'}`)
    }

    // Update daily stats
    await updateStats(supabase, notificationType, transactionData.productId)

    // Apple expects a 200 response
    return new Response(
      JSON.stringify({ received: true }),
      { 
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )

  } catch (error) {
    console.error('Webhook error:', error)
    
    // Still return 200 to prevent Apple from retrying
    // Log the error for investigation
    return new Response(
      JSON.stringify({ received: true, error: 'Processing error logged' }),
      { 
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})

async function updateStats(supabase: any, notificationType: string, productId: string | null) {
  const today = new Date().toISOString().split('T')[0]
  
  // Map notification type to stat column
  const statUpdates: Record<string, string> = {
    'SUBSCRIBED': 'subscriptions_started',
    'DID_RENEW': 'subscriptions_renewed',
    'DID_CHANGE_RENEWAL_STATUS': 'subscriptions_cancelled', // When auto-renew disabled
    'EXPIRED': 'subscriptions_expired',
    'REFUND': 'refunds',
    'DID_FAIL_TO_RENEW': 'billing_issues',
  }

  const statColumn = statUpdates[notificationType]
  if (!statColumn) return

  // Estimate revenue from product ID
  let revenue = 0
  if (productId && (notificationType === 'SUBSCRIBED' || notificationType === 'DID_RENEW')) {
    if (productId.includes('5')) revenue = 5
    if (productId.includes('10')) revenue = 10
    if (productId.includes('25')) revenue = 25
    if (productId.includes('50')) revenue = 50
    if (productId.includes('100')) revenue = 100
  }

  // Upsert stats for today
  const { error } = await supabase.rpc('upsert_apple_stats', {
    p_date: today,
    p_column: statColumn,
    p_revenue: revenue,
  })

  if (error) {
    console.error('Error updating stats:', error)
  }
}
