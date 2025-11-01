-- ============================================================================
-- DIAGNOSTIC SCRIPT - Check Notification System Status
-- ============================================================================
-- Run this script to diagnose notification broadcasting issues
-- ============================================================================

-- 1. Check if notifications table exists and its structure
SELECT 'TABLE STRUCTURE:' as info;
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'notifications'
ORDER BY ordinal_position;

-- 2. Check current RLS policies
SELECT '---' as separator;
SELECT 'CURRENT RLS POLICIES:' as info;
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  cmd,
  CASE 
    WHEN qual IS NOT NULL THEN qual
    ELSE 'N/A'
  END as using_clause,
  CASE 
    WHEN with_check IS NOT NULL THEN with_check
    ELSE 'N/A'
  END as with_check_clause
FROM pg_policies
WHERE tablename = 'notifications'
ORDER BY cmd, policyname;

-- 3. Check if RLS is enabled
SELECT '---' as separator;
SELECT 'RLS STATUS:' as info;
SELECT 
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE tablename = 'notifications';

-- 4. Count total users in database
SELECT '---' as separator;
SELECT 'TOTAL USERS:' as info, COUNT(*) as count FROM users;

-- 5. Count users by role
SELECT '---' as separator;
SELECT 'USERS BY ROLE:' as info;
SELECT role, COUNT(*) as count 
FROM users 
GROUP BY role;

-- 6. Count total notifications
SELECT '---' as separator;
SELECT 'TOTAL NOTIFICATIONS:' as info, COUNT(*) as count FROM notifications;

-- 7. Count notifications by type
SELECT '---' as separator;
SELECT 'NOTIFICATIONS BY TYPE:' as info;
SELECT type, COUNT(*) as count 
FROM notifications 
GROUP BY type;

-- 8. Count notifications per user (top 10)
SELECT '---' as separator;
SELECT 'NOTIFICATIONS PER USER (Top 10):' as info;
SELECT 
  user_id, 
  COUNT(*) as notification_count
FROM notifications
GROUP BY user_id
ORDER BY notification_count DESC
LIMIT 10;

-- 9. Show recent notifications (last 10)
SELECT '---' as separator;
SELECT 'RECENT NOTIFICATIONS (Last 10):' as info;
SELECT 
  id,
  user_id,
  type,
  title,
  message,
  sent_at,
  read
FROM notifications
ORDER BY sent_at DESC
LIMIT 10;

-- ============================================================================
-- INTERPRETATION:
-- ============================================================================
-- After a faculty sends a broadcast notification:
-- - "TOTAL NOTIFICATIONS" should increase by the number of users
-- - "NOTIFICATIONS PER USER" should show equal counts for all users
-- - "RECENT NOTIFICATIONS" should show multiple entries with same title/message
--   but different user_ids
-- ============================================================================
