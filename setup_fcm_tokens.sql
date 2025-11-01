-- ============================================================================
-- FIREBASE FCM INTEGRATION - Database Schema
-- ============================================================================
-- Store FCM tokens for each user so we can send push notifications
-- ============================================================================

-- Create table to store FCM tokens
CREATE TABLE IF NOT EXISTS user_fcm_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  fcm_token TEXT NOT NULL,
  platform TEXT CHECK (platform IN ('android', 'ios', 'web')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  
  -- One token per user per platform
  UNIQUE(user_id, platform)
);

-- Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_user_id 
  ON user_fcm_tokens(user_id);

-- Enable RLS
ALTER TABLE user_fcm_tokens ENABLE ROW LEVEL SECURITY;

-- Policies
DROP POLICY IF EXISTS "Users can manage own FCM tokens" ON user_fcm_tokens;
DROP POLICY IF EXISTS "Faculty can view all FCM tokens" ON user_fcm_tokens;

-- Users can insert/update/delete their own tokens
CREATE POLICY "Users can manage own FCM tokens"
  ON user_fcm_tokens
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Faculty can read all tokens (needed for broadcasting)
CREATE POLICY "Faculty can view all FCM tokens"
  ON user_fcm_tokens
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() 
      AND role = 'faculty'
    )
  );

-- Function to update timestamp
CREATE OR REPLACE FUNCTION update_fcm_token_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update timestamp
DROP TRIGGER IF EXISTS update_user_fcm_tokens_timestamp ON user_fcm_tokens;
CREATE TRIGGER update_user_fcm_tokens_timestamp
  BEFORE UPDATE ON user_fcm_tokens
  FOR EACH ROW
  EXECUTE FUNCTION update_fcm_token_timestamp();

-- ============================================================================
-- Verification
-- ============================================================================
SELECT 'FCM tokens table created!' as status;
SELECT COUNT(*) as token_count FROM user_fcm_tokens;
