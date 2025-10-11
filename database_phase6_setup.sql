-- ============================================================================
-- Campus Connect - Phase 6 Database Setup
-- ============================================================================
-- Run this script in Supabase SQL Editor
-- Project: campus-connect
-- Date: October 11, 2025
-- ============================================================================

-- ============================================================================
-- 1. CREATE SEARCH_HISTORY TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS search_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) NOT NULL,
  query TEXT NOT NULL,
  category TEXT,
  searched_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- ============================================================================
-- 2. CREATE INDEXES FOR PERFORMANCE
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_search_history_user_id 
  ON search_history(user_id);

CREATE INDEX IF NOT EXISTS idx_search_history_searched_at 
  ON search_history(searched_at DESC);

-- ============================================================================
-- 3. ENABLE ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE search_history ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 4. CREATE RLS POLICIES FOR SEARCH_HISTORY
-- ============================================================================

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can view own search history" ON search_history;
DROP POLICY IF EXISTS "Users can insert own search history" ON search_history;
DROP POLICY IF EXISTS "Users can delete own search history" ON search_history;

-- Users can view their own search history
CREATE POLICY "Users can view own search history"
  ON search_history FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own search history
CREATE POLICY "Users can insert own search history"
  ON search_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own search history
CREATE POLICY "Users can delete own search history"
  ON search_history FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- 5. UPDATE NOTIFICATIONS TABLE (ADD TITLE COLUMN)
-- ============================================================================

-- Add title column if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'notifications' 
    AND column_name = 'title'
  ) THEN
    -- Add the column
    ALTER TABLE notifications ADD COLUMN title TEXT;
    
    -- Update existing rows with a default title
    UPDATE notifications 
    SET title = 'Notification' 
    WHERE title IS NULL;
    
    -- Make it NOT NULL
    ALTER TABLE notifications 
    ALTER COLUMN title SET NOT NULL;
    
    RAISE NOTICE 'Added title column to notifications table';
  ELSE
    RAISE NOTICE 'Title column already exists in notifications table';
  END IF;
END $$;

-- ============================================================================
-- 6. VERIFY NOTIFICATIONS RLS POLICIES
-- ============================================================================

-- Ensure RLS is enabled
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Drop and recreate policies to ensure they're correct
DROP POLICY IF EXISTS "Users can view own notifications" ON notifications;
DROP POLICY IF EXISTS "Faculty can create notifications" ON notifications;
DROP POLICY IF EXISTS "Users can update own notifications" ON notifications;
DROP POLICY IF EXISTS "Faculty can delete notifications" ON notifications;

-- Users can view their own notifications
CREATE POLICY "Users can view own notifications"
  ON notifications FOR SELECT
  USING (auth.uid() = user_id);

-- Faculty can create notifications
CREATE POLICY "Faculty can create notifications"
  ON notifications FOR INSERT
  WITH CHECK (
    auth.uid() IN (SELECT id FROM users WHERE role = 'faculty')
  );

-- Users can update their own notifications (mark as read)
CREATE POLICY "Users can update own notifications"
  ON notifications FOR UPDATE
  USING (auth.uid() = user_id);

-- Faculty can delete notifications
CREATE POLICY "Faculty can delete notifications"
  ON notifications FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- 7. VERIFICATION QUERIES
-- ============================================================================

-- Check search_history table structure
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'search_history'
ORDER BY ordinal_position;

-- Check notifications table structure (verify title column)
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'notifications'
ORDER BY ordinal_position;

-- Check RLS policies for search_history
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies
WHERE tablename = 'search_history';

-- Check RLS policies for notifications
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies
WHERE tablename = 'notifications';

-- ============================================================================
-- 8. SAMPLE TEST DATA (OPTIONAL)
-- ============================================================================

-- Uncomment to insert sample notifications for testing
-- Replace <your-user-id> with an actual user ID from your users table

/*
-- Sample welcome notification
INSERT INTO notifications (user_id, type, title, message, read)
VALUES (
  '<your-user-id>',
  'announcement',
  'Welcome to Campus Connect!',
  'Explore events, faculty directory, and campus locations.',
  false
);

-- Sample event notification
INSERT INTO notifications (user_id, type, title, message, read)
VALUES (
  '<your-user-id>',
  'event',
  'New Event: Tech Workshop',
  'Join us for an exciting tech workshop tomorrow at 2 PM in the Computer Lab.',
  false
);

-- Sample reminder notification
INSERT INTO notifications (user_id, type, title, message, read)
VALUES (
  '<your-user-id>',
  'reminder',
  'Library Hours Update',
  'The library will be open until 10 PM starting this week.',
  false
);
*/

-- ============================================================================
-- SETUP COMPLETE!
-- ============================================================================

-- Summary
SELECT 
  'Setup Complete!' as status,
  (SELECT COUNT(*) FROM search_history) as search_history_count,
  (SELECT COUNT(*) FROM notifications) as notifications_count,
  (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'search_history') as search_policies,
  (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'notifications') as notification_policies;

-- ============================================================================
-- NEXT STEPS:
-- 1. Verify all tables and policies are created
-- 2. Test the app with flutter run
-- 3. Check FCM token in logs
-- 4. Send test push notification from Firebase Console
-- 5. Test search functionality
-- 6. Test notification center
-- ============================================================================
