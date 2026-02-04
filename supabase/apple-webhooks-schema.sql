-- ================================================
-- Apple App Store Server Notifications Schema
-- ================================================
-- Stores webhook events from Apple for subscription/purchase tracking

-- Table to store all Apple webhook notifications
CREATE TABLE IF NOT EXISTS apple_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  notification_type TEXT NOT NULL,
  subtype TEXT,
  notification_uuid TEXT UNIQUE,
  
  -- Transaction data
  original_transaction_id TEXT,
  transaction_id TEXT,
  product_id TEXT,
  
  -- Subscription data
  expires_date TIMESTAMPTZ,
  auto_renew_status BOOLEAN,
  is_in_billing_retry BOOLEAN,
  
  -- Environment
  environment TEXT, -- 'Sandbox' or 'Production'
  
  -- Raw payload for reference
  raw_payload JSONB,
  
  -- Timestamps
  signed_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for querying by transaction
CREATE INDEX IF NOT EXISTS idx_apple_notifications_transaction 
ON apple_notifications(original_transaction_id);

-- Index for querying by product
CREATE INDEX IF NOT EXISTS idx_apple_notifications_product 
ON apple_notifications(product_id);

-- Index for querying by type
CREATE INDEX IF NOT EXISTS idx_apple_notifications_type 
ON apple_notifications(notification_type);

-- Summary table for quick stats
CREATE TABLE IF NOT EXISTS apple_notification_stats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date DATE NOT NULL UNIQUE,
  
  -- Counts by type
  subscriptions_started INT DEFAULT 0,
  subscriptions_renewed INT DEFAULT 0,
  subscriptions_cancelled INT DEFAULT 0,
  subscriptions_expired INT DEFAULT 0,
  refunds INT DEFAULT 0,
  billing_issues INT DEFAULT 0,
  
  -- Revenue tracking (estimated from product IDs)
  estimated_revenue DECIMAL(10,2) DEFAULT 0,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE apple_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE apple_notification_stats ENABLE ROW LEVEL SECURITY;

-- Only allow insert from service role (Edge Function)
CREATE POLICY "Service role can insert notifications"
ON apple_notifications FOR INSERT
TO service_role
WITH CHECK (true);

CREATE POLICY "Service role can read notifications"
ON apple_notifications FOR SELECT
TO service_role
USING (true);

CREATE POLICY "Service role can manage stats"
ON apple_notification_stats FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- ================================================
-- RPC Function for Edge Function to update stats
-- ================================================
CREATE OR REPLACE FUNCTION upsert_apple_stats(
  p_date DATE,
  p_column TEXT,
  p_revenue DECIMAL DEFAULT 0
)
RETURNS void AS $$
BEGIN
  -- Insert or update the stats row
  INSERT INTO apple_notification_stats (date, estimated_revenue)
  VALUES (p_date, p_revenue)
  ON CONFLICT (date) DO UPDATE SET
    updated_at = NOW(),
    estimated_revenue = apple_notification_stats.estimated_revenue + p_revenue;
  
  -- Update the specific counter column
  EXECUTE format(
    'UPDATE apple_notification_stats SET %I = %I + 1 WHERE date = $1',
    p_column, p_column
  ) USING p_date;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================
-- Notification Types Reference:
-- ================================================
-- CONSUMPTION_REQUEST - Customer initiated refund
-- DID_CHANGE_RENEWAL_PREF - Changed auto-renew product
-- DID_CHANGE_RENEWAL_STATUS - Enabled/disabled auto-renew
-- DID_FAIL_TO_RENEW - Billing issue
-- DID_RENEW - Subscription renewed
-- EXPIRED - Subscription expired
-- GRACE_PERIOD_EXPIRED - Grace period ended
-- OFFER_REDEEMED - Promotional offer used
-- PRICE_INCREASE - Price increase consent
-- REFUND - Refund processed
-- REFUND_DECLINED - Refund request declined
-- RENEWAL_EXTENDED - Subscription extended
-- REVOKE - Family sharing revoked
-- SUBSCRIBED - New subscription
-- TEST - Test notification
