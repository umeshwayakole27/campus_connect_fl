# COMPLETE NOTIFICATION FIX GUIDE

## Quick Start (Do This First!)

### 1. Apply the Database Fix

```bash
# Navigate to your Supabase Dashboard
# Go to: SQL Editor → New Query
# Copy and paste the contents of: fix_notification_rls.sql
# Click: RUN
```

### 2. Verify the Fix Applied

After running the SQL script, you should see output like:
```
NEW POLICIES:
- Users can view own notifications (SELECT)
- Faculty can create notifications (INSERT)
- Users can update own notifications (UPDATE)  
- Users can delete own notifications (DELETE)

TOTAL USERS IN DATABASE: <number>
```

### 3. Test in the App

```bash
# Run the app with verbose logging
flutter run --verbose

# Watch for these log messages when you send a broadcast:
# 📢 Found X users to notify
# 📢 Successfully inserted X notifications
```

## Detailed Debugging Steps

If notifications still don't work after applying the fix, follow these steps:

### Debug Step 1: Verify Database State

Run `diagnostic_notification.sql` in Supabase SQL Editor.

**Check:**
- [ ] RLS is enabled on notifications table
- [ ] All 4 policies exist
- [ ] Users table has multiple users
- [ ] At least one user has role = 'faculty'

### Debug Step 2: Check App Logs

When you send a notification, you should see:

✅ **Success logs:**
```
📢 NotificationProvider: Broadcasting notification...
📢 Starting broadcast notification...
📢 Fetching all users...
📢 Found 5 users to notify
📢 User IDs: abc-123, def-456, ghi-789...
📢 Inserting 5 notifications...
📢 Successfully inserted 5 notifications
📢 Broadcast complete!
```

❌ **Error logs (if something is wrong):**
```
❌ Error broadcasting notification: <error message>
❌ Stack trace: ...
```

**Common errors and solutions:**

| Error Message | Cause | Solution |
|---------------|-------|----------|
| "new row violates row-level security policy" | RLS policy not updated | Rerun fix_notification_rls.sql |
| "Failed to load notifications" | Network/connection issue | Check internet connection |
| "Found 0 users to notify" | Empty users table | Register users in the app first |
| "permission denied for table users" | Database permissions | Check Supabase project settings |

### Debug Step 3: Verify Data in Supabase

After sending a broadcast from the app:

1. Go to Supabase Dashboard → **Table Editor** → **notifications**
2. Sort by `sent_at` (newest first)
3. Check the most recent notifications

✅ **What you should see:**
- Multiple rows with the SAME title and message
- Each row has a DIFFERENT user_id
- Number of rows = number of users in your database

❌ **What indicates a problem:**
- Only 1 notification row (only sender got it)
- All rows have the same user_id
- No new rows at all

### Debug Step 4: Test with SQL

Run `test_notification_broadcast.sql` and examine the results:

**STEP 5 should show:**
```
title: "Test Broadcast"
users_notified: <total number of users>
```

**STEP 6 should show:**
```
email                    | role    | notification_count
faculty@test.com         | faculty | 1
student1@test.com        | student | 1
student2@test.com        | student | 1
```

If notification_count = 0 for students, the broadcast didn't work.

### Debug Step 5: Check User Authentication

Verify the faculty user is actually authenticated as faculty:

```sql
-- In Supabase SQL Editor, check current user
SELECT auth.uid() as current_user_id;

-- Check if current user is faculty
SELECT id, email, role 
FROM users 
WHERE id = auth.uid();
```

Make sure:
- [ ] auth.uid() returns a valid UUID (not null)
- [ ] The user exists in the users table
- [ ] The user's role is 'faculty' (not 'student')

## Common Issues and Solutions

### Issue: "Policy not found" when running fix script

**Solution:**
```sql
-- Ensure the table exists
SELECT tablename FROM pg_tables WHERE tablename = 'notifications';

-- If it doesn't exist, create it first
-- (Check your initial database setup script)
```

### Issue: Faculty can't access Announce button

**Possible causes:**
- User role is not 'faculty' in database
- AuthProvider not returning correct user role

**Solution:**
```dart
// Check in your app (add debug print)
print('Current user role: ${authProvider.currentUser?.role}');

// Should print: "Current user role: faculty"
```

**If role is wrong, update in database:**
```sql
UPDATE users 
SET role = 'faculty' 
WHERE email = 'yourfaculty@email.com';
```

### Issue: Notifications appear then disappear

**Possible cause:** Real-time subscription conflict

**Solution:**
```dart
// In notification_provider.dart, check subscription logic
// The app subscribes to: user_id = current_user_id
// This should NOT filter out broadcast notifications
```

### Issue: App shows "Announcement sent" but no errors, but database is empty

**Possible causes:**
- Silent transaction rollback
- Async/await issue

**Solution:** 
Check the updated repository code - it now logs every step.
If you see "Successfully inserted X notifications" but database is empty,
there may be a database replication issue.

## Alternative Fix (If Main Fix Doesn't Work)

If the RLS policy fix doesn't work, try this alternative approach:

### Option A: Temporarily Disable RLS (Testing Only!)

```sql
-- WARNING: This disables security! Only for testing!
ALTER TABLE notifications DISABLE ROW LEVEL SECURITY;

-- Test broadcasting from app
-- If it works now, the issue is definitely the RLS policy

-- Re-enable security
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
```

If broadcasting works with RLS disabled, the policy needs adjustment.

### Option B: Use a Database Function

Create a server-side function that bypasses RLS:

```sql
-- Create function (runs with SECURITY DEFINER = bypasses RLS)
CREATE OR REPLACE FUNCTION broadcast_notification(
  p_type TEXT,
  p_title TEXT,
  p_message TEXT,
  p_event_id UUID DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO notifications (user_id, type, title, message, event_id)
  SELECT id, p_type, p_title, p_message, p_event_id
  FROM users;
END;
$$;

-- Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION broadcast_notification TO authenticated;
```

Then update Dart code to call this function instead:

```dart
// In notification_repository.dart
Future<void> broadcastNotification({
  required String type,
  required String title,
  required String message,
  String? eventId,
}) async {
  try {
    await _supabase.rpc('broadcast_notification', params: {
      'p_type': type,
      'p_title': title,
      'p_message': message,
      'p_event_id': eventId,
    });
  } catch (e) {
    debugPrint('Error broadcasting: $e');
    throw Exception('Failed to broadcast notification');
  }
}
```

## Files in This Fix

1. **fix_notification_rls.sql** - Main fix script (RUN THIS FIRST)
2. **diagnostic_notification.sql** - Check database state
3. **test_notification_broadcast.sql** - Verify fix worked
4. **NOTIFICATION_FIX_README.md** - Detailed explanation
5. **COMPLETE_FIX_GUIDE.md** - This file (step-by-step guide)

## Modified Application Files

1. **notification_repository.dart** - Added detailed debug logging
2. **notification_provider.dart** - Added debug logging

## Support Checklist

If you need help, provide:

- [ ] Output from diagnostic_notification.sql
- [ ] App debug logs (flutter run --verbose)
- [ ] Screenshot of Supabase Table Editor (notifications table)
- [ ] Output from test_notification_broadcast.sql
- [ ] Current user role verification (SQL query result)
- [ ] Error message (exact text)

## Success Criteria

You'll know it's working when:

✅ Faculty sends notification from app
✅ Debug log shows "Found X users to notify" (X > 1)
✅ Debug log shows "Successfully inserted X notifications"
✅ Supabase notifications table shows X new rows
✅ Each row has different user_id
✅ Student logs in and sees the notification
✅ Notification shows in student's notification list

---

**Last Updated:** 2025-11-01
**Version:** 2.0 (Enhanced debugging)
