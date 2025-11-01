# ENABLE FIREBASE CLOUD MESSAGING API (LEGACY)

## Current Issue

The Cloud Messaging API (Legacy) is disabled in your Firebase project.
You need to enable it to use FCM for push notifications.

## ✅ How to Enable It

### Step 1: Go to Firebase Console
Visit: https://console.firebase.google.com/project/campus-connect-23fae/settings/cloudmessaging

### Step 2: Enable Cloud Messaging API (Legacy)

You'll see a section that says "Cloud Messaging API (Legacy)" with status: **Disabled**

**Option 1: Click the Link in Firebase Console**
1. Look for a link or button that says "Enable Cloud Messaging API"
2. Click it
3. Follow the prompts to enable

**Option 2: Enable via Google Cloud Console**
1. Click on the link in Firebase that says "Enable in Google Cloud Console"
2. OR go directly to: https://console.cloud.google.com/apis/library/fcm.googleapis.com?project=campus-connect-23fae
3. Click the **"ENABLE"** button
4. Wait a few seconds for it to activate

### Step 3: Verify It's Enabled

Go back to Firebase Console → Cloud Messaging
- Cloud Messaging API (Legacy): Should now say **"Enabled"**
- You'll now see your **Server key** displayed

### Step 4: Copy the Server Key

Once enabled, you'll see:
- **Server key**: `AAAA...` (long string)
- Copy this entire key - you'll need it for Supabase Edge Function

## 🔧 Alternative: Use FCM HTTP v1 API (Newer)

If you can't enable the Legacy API, you can use the newer HTTP v1 API instead.

### Differences:

| Legacy API | HTTP v1 API |
|------------|-------------|
| Simple server key | OAuth 2.0 token |
| Easy to use | More secure |
| Being deprecated | Recommended |

### To Use HTTP v1 API:

I can update the Supabase Edge Function to use HTTP v1 instead.
Let me know if you need this!

## 📋 After Enabling

Once you've enabled it and copied the server key:

1. Go to Supabase Dashboard
2. Edge Functions → Secrets
3. Add secret: `FCM_SERVER_KEY` = `your-copied-key`
4. Deploy the Edge Function:
   ```bash
   supabase functions deploy send-notification
   ```

## ⚠️ Important Notes

**Why is it disabled?**
- Google is transitioning to HTTP v1 API
- Legacy API still works but needs manual enabling
- It's safe to enable for your app

**Will it cost money?**
- NO! FCM is completely FREE
- Unlimited push notifications
- No charges for enabling the API

## 🆘 If You Can't Enable It

If the Legacy API cannot be enabled (blocked by Google), then:

**Option 1:** Use HTTP v1 API (I can update the code)
**Option 2:** Use a different approach (Supabase Realtime, etc.)

Let me know what you see and I'll help you!

---

**Quick Link:**
https://console.cloud.google.com/apis/library/fcm.googleapis.com?project=campus-connect-23fae

Click "ENABLE" and you're done! ✅
