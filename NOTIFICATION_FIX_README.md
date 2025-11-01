# Notification Broadcasting Fix

## Problem
When faculty sends notifications from their login, the notifications only appear in their own account instead of being received by all users.

## Root Cause
The issue is with the **Row Level Security (RLS) policy** in the Supabase database for the `notifications` table.

### Current Policy (Broken)
```sql
CREATE POLICY "Faculty can create notifications"
  ON notifications FOR INSERT
  WITH CHECK (
    auth.uid() IN (SELECT id FROM users WHERE role = 'faculty')
  );
```

This policy has a problem: The `WITH CHECK` clause is evaluated for **each row being inserted**, and it only verifies that the authenticated user is a faculty member. However, when inserting a row, Supabase also implicitly checks that the user has permission to set all column values, including `user_id`.

When faculty broadcasts a notification using `broadcastNotification()`, the code tries to insert multiple rows with different `user_id` values (one for each user). The RLS policy rejects these insertions because the `user_id` in each row doesn't match `auth.uid()`.

## Solution - Step by Step

### Step 1: Run Diagnostic Script (Optional)
To check current database state:

1. Go to Supabase Dashboard → **SQL Editor**
2. Copy contents of `diagnostic_notification.sql`
3. Run it to see current policies and data
4. Note any errors or unexpected values

### Step 2: Apply the Fix
Execute the SQL script `fix_notification_rls.sql`:

1. Go to Supabase Dashboard → **SQL Editor**
2. Copy the **entire contents** of `fix_notification_rls.sql`
3. Paste and click **RUN**
4. Verify you see "NEW POLICIES" section in the output
5. Check that all 4 policies are listed:
   - Users can view own notifications (SELECT)
   - Faculty can create notifications (INSERT)
   - Users can update own notifications (UPDATE)
   - Users can delete own notifications (DELETE)

### Step 3: Test the Fix in the App

1. **Open Flutter app** and check the debug console/logs
2. **Login as Faculty**
3. **Go to Notifications Screen**
4. **Click the "Announce" floating action button**
5. **Fill in the form:**
   - Type: Announcement
   - Title: Test Broadcast
   - Message: Testing notification broadcast to all users
6. **Click "Send"**
7. **Watch the debug console** for these logs:
   ```
   📢 NotificationProvider: Broadcasting notification...
   📢 Starting broadcast notification...
   📢 Fetching all users...
   📢 Found X users to notify
   📢 Inserting X notifications...
   📢 Successfully inserted X notifications
   📢 Broadcast complete!
   ```
8. **If you see errors**, note the exact error message
9. **Go to Supabase Dashboard → Table Editor → notifications**
10. **Verify**: You should see one notification row for EACH user
11. **Login as a different user (student)**
12. **Go to Notifications Screen**
13. **You should see the broadcast notification**

## Troubleshooting

### Issue 1: "Failed to broadcast notification" Error

**Possible Causes:**
- RLS policy not updated correctly
- Faculty user doesn't have proper role in database

**Solution:**
```sql
-- Check faculty user role in Supabase SQL Editor
SELECT id, email, role FROM users WHERE role = 'faculty';

-- If role is wrong, update it:
UPDATE users SET role = 'faculty' WHERE email = 'faculty@example.com';
```

### Issue 2: No Users Found (Found 0 users to notify)

**Possible Cause:** Empty users table

**Solution:**
```sql
-- Check total users
SELECT COUNT(*) FROM users;

-- If empty, you need to register users first in the app
```

### Issue 3: RLS Policy Error When Inserting

**Error Message:** "new row violates row-level security policy"

**Solution:** The fix script didn't apply correctly. Run this:

```sql
-- Completely disable RLS temporarily to test
ALTER TABLE notifications DISABLE ROW LEVEL SECURITY;

-- Try broadcasting again from the app
-- If it works, the issue is definitely the RLS policy

-- Re-enable RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Then rerun fix_notification_rls.sql
```

### Issue 4: Notifications Created But Not Visible to Other Users

**Possible Causes:**
- SELECT policy is too restrictive
- User IDs don't match

**Solution:**
```sql
-- Check recent notifications
SELECT 
  n.id,
  n.user_id,
  u.email,
  n.title,
  n.message,
  n.sent_at
FROM notifications n
LEFT JOIN users u ON n.user_id = u.id
ORDER BY n.sent_at DESC
LIMIT 20;

-- Verify user_id values match actual user IDs
SELECT id, email, role FROM users;
```

### Issue 5: App Shows Success But No Notifications in Database

**Possible Cause:** Transaction rolled back silently

**Solution:** Check Supabase logs:
1. Go to Supabase Dashboard → **Logs** → **Postgres Logs**
2. Look for errors around the time you sent the notification
3. Filter by "error" or "failed"

## Verification Checklist

After applying the fix, verify:

- [ ] SQL script ran without errors
- [ ] All 4 RLS policies exist (run diagnostic script)
- [ ] RLS is enabled on notifications table
- [ ] Faculty user has correct role in database
- [ ] Debug logs show "Found X users to notify" where X > 1
- [ ] Debug logs show "Successfully inserted X notifications"
- [ ] Supabase Table Editor shows multiple notification rows
- [ ] Each notification row has a different user_id
- [ ] Student login shows the broadcast notification
- [ ] Notification has correct title and message

## Files Modified

### Database Scripts
- ✅ `fix_notification_rls.sql` - Comprehensive SQL fix with all policies
- ✅ `diagnostic_notification.sql` - Diagnostic queries to check system state

### Application Code
- ✅ `lib/features/notifications/data/notification_repository.dart` - Added detailed debug logging
- ✅ `lib/features/notifications/presentation/notification_provider.dart` - Added debug logging

## How It Works

### New Policy (Fixed)
```sql
CREATE POLICY "Faculty can create notifications"
  ON notifications FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() 
      AND role = 'faculty'
    )
  );
```

This new policy:
- ✅ Verifies the authenticated user (`auth.uid()`) is a faculty member
- ✅ Allows faculty to insert notifications with ANY `user_id` value
- ✅ Does NOT restrict the `user_id` column value
- ✅ Enables broadcasting to all users

### Broadcast Flow
```
Faculty Creates Notification
    ↓
NotificationsScreen._showCreateNotificationDialog()
    ↓
NotificationProvider.broadcastNotification()
    ↓
NotificationRepository.broadcastNotification()
    ↓
1. Fetches all user IDs: SELECT id FROM users
2. Creates notification map for each user
3. Batch inserts: INSERT INTO notifications (user_id, type, title, message) VALUES (...)
    ↓
✅ RLS Policy CHECK: Is auth.uid() a faculty member? YES → Allow
    ↓
Supabase stores notifications (one row per user)
    ↓
Real-time subscription triggers for each user
    ↓
All users receive notification via WebSocket
```

## Security

The fix maintains security:
- ✅ Only faculty can create/broadcast notifications
- ✅ Students cannot create notifications
- ✅ Users can only view their own notifications
- ✅ Users can only update/delete their own notifications

## Need More Help?

If the issue persists:

1. **Collect debug logs:** Run the app with `flutter run --verbose` and save the output
2. **Export diagnostic results:** Run `diagnostic_notification.sql` and save the output
3. **Check Supabase logs:** Export relevant error logs from Supabase Dashboard
4. **Verify policy:** Run this in Supabase SQL Editor:
   ```sql
   SELECT policyname, cmd, with_check 
   FROM pg_policies 
   WHERE tablename = 'notifications' 
   AND policyname = 'Faculty can create notifications';
   ```

The debug logs will show exactly where the process fails.
