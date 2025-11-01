-- ============================================================================
-- COMPLETE NOTIFICATION BROADCAST FIX
-- ============================================================================
-- This script fixes BOTH issues:
-- 1. Users table RLS (prevents fetching user list)
-- 2. Notifications table RLS (prevents inserting for all users)
-- ============================================================================

-- ============================================================================
-- PART 1: FIX USERS TABLE RLS
-- ============================================================================

SELECT '========================================' as separator;
SELECT 'FIXING USERS TABLE RLS...' as step;
SELECT '========================================' as separator;

-- Enable RLS on users table (if not already enabled)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Drop existing policies that might be too restrictive
DROP POLICY IF EXISTS "Users can view own profile" ON users;
DROP POLICY IF EXISTS "Users can view all user profiles" ON users;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON users;

-- Create policy to allow ALL authenticated users to read user data
-- This is needed so faculty can fetch all user IDs for broadcasting
CREATE POLICY "Enable read access for authenticated users"
  ON users
  FOR SELECT
  USING (auth.role() = 'authenticated');

-- Create policy to allow users to update their own profile
CREATE POLICY "Users can update own profile"
  ON users
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Create policy to allow users to insert their own profile
CREATE POLICY "Users can insert own profile"
  ON users
  FOR INSERT
  WITH CHECK (auth.uid() = id);

SELECT 'Users table RLS policies created!' as status;

-- ============================================================================
-- PART 2: FIX NOTIFICATIONS TABLE RLS
-- ============================================================================

SELECT '========================================' as separator;
SELECT 'FIXING NOTIFICATIONS TABLE RLS...' as step;
SELECT '========================================' as separator;

-- Enable RLS on notifications table
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Drop all existing notification policies
DROP POLICY IF EXISTS "Users can view own notifications" ON notifications;
DROP POLICY IF EXISTS "Faculty can create notifications" ON notifications;
DROP POLICY IF EXISTS "Users can update own notifications" ON notifications;
DROP POLICY IF EXISTS "Users can delete own notifications" ON notifications;
DROP POLICY IF EXISTS "Faculty can delete notifications" ON notifications;

-- Policy 1: Users can view their own notifications
CREATE POLICY "Users can view own notifications"
  ON notifications
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy 2: Faculty can insert notifications for ANY user (CRITICAL FIX)
CREATE POLICY "Faculty can create notifications"
  ON notifications
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() 
      AND role = 'faculty'
    )
  );

-- Policy 3: Users can update their own notifications (mark as read)
CREATE POLICY "Users can update own notifications"
  ON notifications
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy 4: Users can delete their own notifications
CREATE POLICY "Users can delete own notifications"
  ON notifications
  FOR DELETE
  USING (auth.uid() = user_id);

SELECT 'Notifications table RLS policies created!' as status;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

SELECT '========================================' as separator;
SELECT 'VERIFICATION' as step;
SELECT '========================================' as separator;

-- Check users table policies
SELECT 'USERS TABLE POLICIES:' as info;
SELECT 
  policyname,
  cmd
FROM pg_policies
WHERE tablename = 'users'
ORDER BY cmd, policyname;

-- Check notifications table policies
SELECT 'NOTIFICATIONS TABLE POLICIES:' as info;
SELECT 
  policyname,
  cmd
FROM pg_policies
WHERE tablename = 'notifications'
ORDER BY cmd, policyname;

-- Count users
SELECT 'TOTAL USERS:' as info;
SELECT COUNT(*) as total_users FROM users;

-- Count notifications
SELECT 'TOTAL NOTIFICATIONS:' as info;
SELECT COUNT(*) as total_notifications FROM notifications;

SELECT '========================================' as separator;
SELECT 'FIX COMPLETE!' as status;
SELECT 'Now test broadcasting from the app.' as instruction;
SELECT '========================================' as separator;

-- ============================================================================
-- TESTING INSTRUCTIONS:
-- ============================================================================
-- 1. Run this entire script in Supabase SQL Editor
-- 2. Restart your app on the phone
-- 3. Login as faculty
-- 4. Send a broadcast notification
-- 5. Check debug logs for: "📢 Found X users to notify" (X should be > 1)
-- 6. Login as student on another account
-- 7. Verify student received the notification
-- ============================================================================
