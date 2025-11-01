# ✅ SUPABASE EDGE FUNCTIONS IMPLEMENTATION - FINAL GUIDE

## What I've Implemented

I've implemented Firebase FCM notifications using **Supabase Edge Functions** instead of Firebase Cloud Functions.

**Why?** No billing upgrade required! Supabase Edge Functions are FREE and work great!

## 📁 Files Created

1. ✅ `supabase/functions/send-notification/index.ts` - Edge function to send FCM
2. ✅ Updated `notification_repository.dart` - Calls Supabase function
3. ✅ `fcm_service.dart` - Saves FCM tokens to database
4. ✅ `setup_fcm_tokens.sql` - Database schema (optional)
5. ✅ `COMPLETE_BROADCAST_FIX.sql` - Fixes RLS policies

## 🚀 Deployment Steps

### Step 1: Get Your Firebase Server Key

1. Go to Firebase Console: https://console.firebase.google.com/project/campus-connect-23fae/settings/cloudmessaging
2. Under "Cloud Messaging API (Legacy)", find **Server key**
3. Copy the server key (starts with `AAAA...`)

### Step 2: Set Environment Variable in Supabase

1. Go to Supabase Dashboard: https://app.supabase.com/project/_/settings/functions
2. Click "Edge Functions" → "Secrets"
3. Add new secret:
   - Name: `FCM_SERVER_KEY`
   - Value: Your Firebase server key from Step 1

### Step 3: Install Supabase CLI (if not installed)

```bash
# Install Supabase CLI
npm install -g supabase
```

### Step 4: Login to Supabase

```bash
supabase login
```

### Step 5: Link to Your Supabase Project

```bash
cd /home/umesh/UserData/FlutterDartProjects/campus_connect_fl
supabase link --project-ref YOUR_PROJECT_REF
```

**Find YOUR_PROJECT_REF:**
- Go to Supabase Dashboard → Project Settings
- Copy the "Reference ID"

### Step 6: Deploy the Edge Function

```bash
cd /home/umesh/UserData/FlutterDartProjects/campus_connect_fl
supabase functions deploy send-notification
```

### Step 7: Run Database Fixes

In Supabase SQL Editor, run:
1. `COMPLETE_BROADCAST_FIX.sql` - Fixes RLS policies
2. `setup_fcm_tokens.sql` (optional) - For token storage

### Step 8: Rebuild the App

```bash
flutter clean
flutter pub get
flutter run -d RZCY51YC1GW
```

## 📱 How It Works

```
Faculty Sends Notification
    ↓
App calls Supabase Edge Function
    ↓
Edge Function sends to FCM topic "all_users"
    ↓
Firebase sends push to ALL devices ✅
    ↓
Also saves to database for history ✅
```

## 🧪 Testing

### Test 1: From Firebase Console
1. Firebase Console → Cloud Messaging
2. Send test message → Topic: `all_users`
3. All devices should receive it!

### Test 2: From App
1. Login as faculty
2. Send notification via Announce button
3. Watch logs:
   ```
   📢 Calling Supabase Edge Function...
   📢 Supabase response: {success: true}
   📢 ✅ Broadcast complete!
   ```
4. Check other devices for push notification!

## 🔍 Debug Checklist

If notifications don't work, check:

- [ ] FCM_SERVER_KEY set in Supabase secrets
- [ ] Edge function deployed successfully
- [ ] Users subscribed to topic 'all_users'
- [ ] App has notification permissions
- [ ] COMPLETE_BROADCAST_FIX.sql executed
- [ ] Internet connection working

## 💰 Cost

**Supabase Edge Functions FREE Tier:**
- 500,000 invocations/month - FREE
- 2GB egress/month - FREE

**Firebase FCM:**
- Unlimited push notifications - FREE

**Your app usage:** ~1,000 notifications/month = **$0**

## ⚡ Quick Commands

```bash
# Deploy function
cd /home/umesh/UserData/FlutterDartProjects/campus_connect_fl
supabase functions deploy send-notification

# View logs
supabase functions logs send-notification

# Test locally
supabase functions serve send-notification
```

## 🎯 What's Next

1. ✅ Deploy the Supabase Edge Function
2. ✅ Test from app
3. ✅ Verify push notifications work
4. 🎉 Enjoy working notifications!

## 🆘 Troubleshooting

### Issue: "Function not found"
**Solution:** Deploy again: `supabase functions deploy send-notification`

### Issue: "FCM error: Unauthorized"
**Solution:** Check FCM_SERVER_KEY is correct in Supabase secrets

### Issue: "No devices receiving"
**Solution:**
- Check users subscribed to 'all_users' topic
- Test from Firebase Console first
- Check app logs for FCM token

### Issue: "RLS policy error"
**Solution:** Run `COMPLETE_BROADCAST_FIX.sql` in Supabase

## 📚 Alternative: If You Can't Deploy Edge Function

If Supabase deployment fails, you can:

**Option A:** Upgrade Firebase to Blaze and use Firebase Functions
**Option B:** Use direct HTTP call from app (less secure)
**Option C:** Fix RLS and use database-only (no push when app closed)

---

**Ready to deploy? Follow the steps above!**

The Edge Function is simpler than Firebase Functions and doesn't require billing! 🚀
