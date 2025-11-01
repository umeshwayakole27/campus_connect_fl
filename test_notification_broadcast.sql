-- ============================================================================
-- TEST NOTIFICATION BROADCAST - Manual Test
-- ============================================================================
-- This script manually tests if notification broadcasting works
-- Run this after fixing the RLS policies
-- ============================================================================

-- Step 1: Check you have users in the database
SELECT 'STEP 1: Checking users...' as step;
SELECT id, email, role FROM users ORDER BY role, email;

-- Step 2: Get a faculty user ID (replace with actual faculty ID)
-- Copy one of the faculty user IDs from above
SELECT 'STEP 2: Enter faculty user ID below' as step;
-- REPLACE 'your-faculty-id-here' with actual faculty UUID from step 1
-- Example: 'd4e5f6a7-b8c9-0d1e-2f3a-4b5c6d7e8f9a'

-- Step 3: Simulate what the app does - create notifications for all users
-- This tests if the RLS policy allows it

-- First, let's see what notifications we currently have
SELECT 'STEP 3: Current notification count' as step;
SELECT COUNT(*) as total_notifications FROM notifications;

-- Now try to insert test notifications for all users
-- This mimics what broadcastNotification() does
SELECT 'STEP 4: Attempting broadcast insert...' as step;

-- REPLACE 'your-faculty-id-here' with the actual faculty user ID
-- Note: This will fail if you're not authenticated as faculty in Supabase
-- The real test must be done from the Flutter app

/*
-- Uncomment this block to test (replace your-faculty-id-here):
INSERT INTO notifications (user_id, type, title, message)
SELECT 
  id as user_id,
  'announcement' as type,
  'SQL Test Broadcast' as title,
  'This is a test notification created directly from SQL' as message
FROM users;
*/

-- Step 5: After running the app's broadcast, check results
SELECT 'STEP 5: Check if broadcast worked' as step;
SELECT 
  n.title,
  COUNT(*) as users_notified,
  MIN(n.sent_at) as sent_at
FROM notifications n
WHERE n.title = 'Test Broadcast' -- Replace with your test title
GROUP BY n.title
ORDER BY MIN(n.sent_at) DESC;

-- Step 6: Verify each user got the notification
SELECT 'STEP 6: Notifications per user for recent broadcast' as step;
SELECT 
  u.email,
  u.role,
  COUNT(n.id) as notification_count
FROM users u
LEFT JOIN notifications n ON u.id = n.user_id 
  AND n.title = 'Test Broadcast' -- Replace with your test title
GROUP BY u.id, u.email, u.role
ORDER BY u.role, u.email;

-- ============================================================================
-- EXPECTED RESULTS:
-- ============================================================================
-- If broadcasting works correctly:
-- - STEP 5 should show: users_notified = total number of users
-- - STEP 6 should show: notification_count = 1 for ALL users
-- 
-- If broadcasting fails:
-- - STEP 5 will show: users_notified = 1 (only faculty member)
-- - STEP 6 will show: notification_count = 0 for students
-- ============================================================================
