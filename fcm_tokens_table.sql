-- SQL Schema for FCM tokens storage
-- This table stores Firebase Cloud Messaging tokens for push notifications

CREATE TABLE IF NOT EXISTS user_fcm_tokens (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    fcm_token TEXT NOT NULL,
    platform VARCHAR(20) NOT NULL CHECK (platform IN ('android', 'ios', 'web')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, platform)
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_user_id ON user_fcm_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_platform ON user_fcm_tokens(platform);

-- Enable Row Level Security
ALTER TABLE user_fcm_tokens ENABLE ROW LEVEL SECURITY;

-- RLS Policies for user_fcm_tokens
-- Users can manage their own tokens
CREATE POLICY "Users can manage own FCM tokens" ON user_fcm_tokens
    FOR ALL USING (auth.uid() = user_id);

-- Allow service role to read all tokens (for sending notifications)
CREATE POLICY "Service can read all FCM tokens" ON user_fcm_tokens
    FOR SELECT TO service_role
    USING (true);

-- Create trigger for updated_at
CREATE TRIGGER update_user_fcm_tokens_updated_at 
    BEFORE UPDATE ON user_fcm_tokens
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
