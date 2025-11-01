# NOTIFICATION BROADCAST - ROOT CAUSE ANALYSIS

## The Real Problem

After SQL fixes, notifications still only appear for the sender. This means:

**The issue is NOT with inserting notifications into the database.**
**The issue is WITH FETCHING THE USER LIST.**

## Root Cause

When the app calls `broadcastNotification()`, it does:
```dart
final usersResponse = await _supabase
    .from('users')
    .select('id');
```

**If the `users` table has RLS enabled and no policy allows SELECT, this query returns 0 rows!**

The app then thinks there are 0 users, so it creates 0 notifications.

## Proof

Look at the debug logs when you send a notification:
- ❌ If you see: `📢 Found 0 users to notify` → RLS on users table is blocking
- ✅ If you see: `📢 Found 5 users to notify` → Users table SELECT is working

## The Fix

### Step 1: Run this SQL script
```sql
-- File: fix_users_table_rls.sql
```

This adds a policy to allow authenticated users to SELECT from the users table.

### Step 2: Verify in Supabase

1. Go to Supabase Dashboard → **Authentication** → **Policies** → **users** table
2. Check if there's a policy for SELECT
3. You should see: "Enable read access for authenticated users"

### Step 3: Test Again

1. Restart the app on your phone
2. Login as faculty
3. Send a test notification
4. **WATCH THE DEBUG LOGS** - you should see:
   ```
   📢 Fetching all users...
   📢 Found X users to notify (where X > 1)
   📢 Inserting X notifications...
   ```

### Step 4: Verify in Database

Run `verify_broadcast.sql` to check:
- How many users exist
- How many notifications were created
- If each user got a notification

## Why This Happens

Supabase Row Level Security (RLS) is VERY strict:
- If a table has RLS enabled
- And there's NO policy allowing an operation
- That operation is BLOCKED (returns no data)

The `users` table likely has:
- ✅ RLS enabled (good for security)
- ❌ No SELECT policy (blocking our broadcast function)

## Alternative Fix (If First Fix Doesn't Work)

If you still can't read from users table, use a Postgres function:

```sql
-- Create a function that bypasses RLS
CREATE OR REPLACE FUNCTION get_all_user_ids()
RETURNS TABLE(user_id UUID)
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT id FROM users;
$$;

GRANT EXECUTE ON FUNCTION get_all_user_ids() TO authenticated;
```

Then update the Dart code:
```dart
// Instead of:
final usersResponse = await _supabase.from('users').select('id');

// Use:
final usersResponse = await _supabase.rpc('get_all_user_ids');
```

## Diagnostic Steps

### 1. Check users table RLS
```sql
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'users';
```

### 2. Check users table policies
```sql
SELECT * FROM pg_policies WHERE tablename = 'users';
```

### 3. Test SELECT as authenticated user
Login to Supabase SQL Editor and run:
```sql
SELECT COUNT(*) FROM users;
```

If this returns 0 or gives an error, RLS is blocking you.

## Files to Use

1. **fix_users_table_rls.sql** - Fixes users table RLS (RUN THIS FIRST)
2. **verify_broadcast.sql** - Verifies if broadcast worked
3. **fix_notification_rls.sql** - Fixes notifications table RLS (already done)

## Expected Debug Logs

✅ **Working broadcast:**
```
📢 NotificationProvider: Broadcasting notification...
📢 Starting broadcast notification...
📢 Fetching all users...
📢 Found 5 users to notify
📢 User IDs: abc-123, def-456, ghi-789, ...
📢 Inserting 5 notifications...
📢 Successfully inserted 5 notifications
📢 Broadcast complete!
```

❌ **Broken broadcast (users table blocked):**
```
📢 NotificationProvider: Broadcasting notification...
📢 Starting broadcast notification...
📢 Fetching all users...
📢 Found 0 users to notify  ← THIS IS THE PROBLEM
📢 Inserting 0 notifications...
📢 Successfully inserted 0 notifications
📢 Broadcast complete!
```

## Quick Test

Run this in Supabase SQL Editor while logged in as faculty:

```sql
-- This is what the app does
SELECT id FROM users;
```

If it returns rows → users table is OK
If it returns nothing → users table RLS is blocking

---

**Next Step:** Run `fix_users_table_rls.sql` in Supabase!
