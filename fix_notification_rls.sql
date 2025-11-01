-- ============================================================================
-- Fix Notification Broadcasting Issue - COMPREHENSIVE FIX
-- ============================================================================
-- This script fixes the RLS policy to allow faculty to create notifications
-- for ALL users, not just themselves.
-- ============================================================================

-- Step 1: Show current policies
SELECT 'CURRENT POLICIES:' as info;
SELECT 
  policyname,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'notifications';

-- Step 2: Drop ALL existing notification policies
DROP POLICY IF EXISTS "Users can view own notifications" ON notifications;
DROP POLICY IF EXISTS "Faculty can create notifications" ON notifications;
DROP POLICY IF EXISTS "Users can update own notifications" ON notifications;
DROP POLICY IF EXISTS "Faculty can delete notifications" ON notifications;
DROP POLICY IF EXISTS "Users can delete own notifications" ON notifications;

-- Step 3: Recreate all policies with correct permissions

-- Policy 1: Users can view their own notifications
CREATE POLICY "Users can view own notifications"
  ON notifications FOR SELECT
  USING (auth.uid() = user_id);

-- Policy 2: Faculty can insert notifications for ANY user (FIXED)
CREATE POLICY "Faculty can create notifications"
  ON notifications FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() 
      AND role = 'faculty'
    )
  );

-- Policy 3: Users can update their own notifications (mark as read)
CREATE POLICY "Users can update own notifications"
  ON notifications FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy 4: Users can delete their own notifications
CREATE POLICY "Users can delete own notifications"
  ON notifications FOR DELETE
  USING (auth.uid() = user_id);

-- Step 4: Ensure RLS is enabled
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Step 5: Verify the policies were created correctly
SELECT 'NEW POLICIES:' as info;
SELECT 
  policyname,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'notifications'
ORDER BY cmd, policyname;

-- Step 6: Test query to see all users (this should work for faculty)
SELECT 'TOTAL USERS IN DATABASE:' as info, COUNT(*) as count FROM users;

-- ============================================================================
-- TESTING INSTRUCTIONS:
-- ============================================================================
-- After running this script:
-- 1. Login as faculty in the app
-- 2. Send a test notification
-- 3. Check the Supabase dashboard -> Table Editor -> notifications
-- 4. You should see one notification row for EACH user
-- 5. Login as a student and check if notification appears
-- ============================================================================
