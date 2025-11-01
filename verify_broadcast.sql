-- ============================================================================
-- VERIFY BROADCAST - Quick Check Script
-- ============================================================================
-- Run this AFTER sending a broadcast notification from the app
-- ============================================================================

-- 1. Check total users in database
SELECT '=== TOTAL USERS ===' as info;
SELECT COUNT(*) as total_users, 
       SUM(CASE WHEN role = 'faculty' THEN 1 ELSE 0 END) as faculty_count,
       SUM(CASE WHEN role = 'student' THEN 1 ELSE 0 END) as student_count
FROM users;

-- 2. Check total notifications
SELECT '=== TOTAL NOTIFICATIONS ===' as info;
SELECT COUNT(*) as total_notifications FROM notifications;

-- 3. Check most recent notifications (last 5)
SELECT '=== RECENT NOTIFICATIONS ===' as info;
SELECT 
  id,
  user_id,
  type,
  title,
  LEFT(message, 50) as message_preview,
  sent_at,
  read
FROM notifications
ORDER BY sent_at DESC
LIMIT 5;

-- 4. Check notifications per user
SELECT '=== NOTIFICATIONS PER USER ===' as info;
SELECT 
  u.email,
  u.role,
  COUNT(n.id) as notification_count
FROM users u
LEFT JOIN notifications n ON u.id = n.user_id
GROUP BY u.id, u.email, u.role
ORDER BY u.role, u.email;

-- 5. Check the LAST broadcast (notifications with same title sent around same time)
SELECT '=== LAST BROADCAST GROUP ===' as info;
SELECT 
  title,
  COUNT(*) as recipients,
  MIN(sent_at) as first_sent,
  MAX(sent_at) as last_sent
FROM notifications
WHERE sent_at > NOW() - INTERVAL '1 hour'
GROUP BY title
ORDER BY first_sent DESC
LIMIT 3;

-- 6. Check RLS policies
SELECT '=== RLS POLICIES ===' as info;
SELECT 
  policyname,
  cmd,
  CASE WHEN qual IS NOT NULL THEN LEFT(qual, 100) ELSE 'N/A' END as using_check,
  CASE WHEN with_check IS NOT NULL THEN LEFT(with_check, 100) ELSE 'N/A' END as with_check
FROM pg_policies
WHERE tablename = 'notifications'
ORDER BY cmd, policyname;

-- ============================================================================
-- WHAT TO LOOK FOR:
-- ============================================================================
-- If broadcast worked:
--   - TOTAL USERS should show multiple users (e.g., 5 users)
--   - NOTIFICATIONS PER USER should show equal counts for all users
--   - LAST BROADCAST GROUP should show recipients = total users
--
-- If broadcast failed:
--   - NOTIFICATIONS PER USER will show 1 for faculty, 0 for students
--   - LAST BROADCAST GROUP will show recipients = 1
-- ============================================================================
