# Apple App Store Server Notifications Setup

This document explains how to set up Apple's webhook notifications for tracking in-app purchases and subscriptions.

## What This Does

When users make purchases, Apple will send notifications to your server for:
- New subscriptions
- Subscription renewals
- Subscription cancellations
- Subscription expirations
- Refunds
- Billing issues

## Setup Steps

### 1. Run the Database Migration

In your Supabase SQL Editor, run:
```sql
-- Copy contents from: supabase/apple-webhooks-schema.sql
```

This creates:
- `apple_notifications` - Stores all webhook events
- `apple_notification_stats` - Daily summary statistics
- `upsert_apple_stats` - Helper function for stats

### 2. Deploy the Edge Function

```bash
cd "/Users/darrengalvin/Documents/GIT PROJECTS/deepdive"
supabase functions deploy apple-webhook
```

### 3. Get Your Webhook URL

After deploying, your webhook URL will be:
```
https://[YOUR-PROJECT-REF].supabase.co/functions/v1/apple-webhook
```

Find your project ref in Supabase Dashboard > Settings > General.

### 4. Configure App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app: **Below the Surface**
3. Go to **App Information** (in General section)
4. Scroll to **App Store Server Notifications**
5. Enter your URLs:

**Production Server URL:**
```
https://[YOUR-PROJECT-REF].supabase.co/functions/v1/apple-webhook
```

**Sandbox Server URL:** (optional, same URL works)
```
https://[YOUR-PROJECT-REF].supabase.co/functions/v1/apple-webhook
```

6. Select **Version 2** notifications (recommended)
7. Click **Save**

### 5. Test the Setup

Apple provides a test notification feature:
1. In App Store Connect, go to your app
2. Under Subscriptions or In-App Purchases
3. Look for "Send Test Notification" option
4. Check your Supabase database for the test event

## Viewing Data

### In Supabase Dashboard

Query recent notifications:
```sql
SELECT 
  notification_type,
  product_id,
  environment,
  created_at
FROM apple_notifications
ORDER BY created_at DESC
LIMIT 20;
```

View daily stats:
```sql
SELECT * FROM apple_notification_stats
ORDER BY date DESC;
```

### In Admin Panel (Future)

The admin panel can be extended to show:
- Real-time subscription metrics
- Revenue tracking
- Cancellation trends

## Notification Types

| Type | Description |
|------|-------------|
| `SUBSCRIBED` | New subscription started |
| `DID_RENEW` | Subscription successfully renewed |
| `DID_CHANGE_RENEWAL_STATUS` | Auto-renew enabled/disabled |
| `DID_FAIL_TO_RENEW` | Billing issue, subscription at risk |
| `EXPIRED` | Subscription ended |
| `REFUND` | Refund was processed |
| `GRACE_PERIOD_EXPIRED` | Billing retry period ended |

## Security Notes

- The Edge Function accepts any POST request from Apple's servers
- In production, you should verify the JWS signature using Apple's public key
- All data is stored but not exposed publicly (RLS enabled)
- Only the service_role can read/write notification data

## Troubleshooting

**Notifications not arriving:**
1. Check the Edge Function logs in Supabase Dashboard
2. Verify the URL is correct in App Store Connect
3. Ensure the function is deployed

**Errors in logs:**
1. Check the raw_payload column for the original data
2. Apple's payload structure may have changed

**Testing locally:**
```bash
supabase functions serve apple-webhook
```

Then use curl to simulate:
```bash
curl -X POST http://localhost:54321/functions/v1/apple-webhook \
  -H "Content-Type: application/json" \
  -d '{"notificationType": "TEST"}'
```
