# FIREBASE HTTP v1 API SETUP GUIDE

## ✅ Updated Implementation

I've updated the Supabase Edge Function to use **Firebase Cloud Messaging HTTP v1 API** (the newer, recommended API).

**Why this is better:**
- ✅ More secure (OAuth 2.0)
- ✅ Recommended by Google
- ✅ Won't be deprecated
- ✅ Still completely FREE

## 🔑 Get Firebase Service Account Credentials

### Step 1: Go to Firebase Console

Visit: https://console.firebase.google.com/project/campus-connect-23fae/settings/serviceaccounts/adminsdk

### Step 2: Generate New Private Key

1. Click on "Service accounts" tab
2. Click "Generate new private key" button
3. Confirm by clicking "Generate key"
4. A JSON file will download to your computer
   - File name: `campus-connect-23fae-firebase-adminsdk-xxxxx.json`

### Step 3: Open the JSON File

The file contains something like:
```json
{
  "type": "service_account",
  "project_id": "campus-connect-23fae",
  "private_key_id": "...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xxxxx@campus-connect-23fae.iam.gserviceaccount.com",
  "client_id": "...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "..."
}
```

**⚠️ IMPORTANT:** Keep this file SECRET! Never commit it to git!

### Step 4: Copy the ENTIRE JSON Content

Copy the entire content of the JSON file (everything from `{` to `}`).

## 🚀 Deploy to Supabase

### Step 1: Add Service Account to Supabase Secrets

1. Go to Supabase Dashboard
2. Navigate to: Edge Functions → Secrets
3. Add a new secret:
   - **Name:** `FIREBASE_SERVICE_ACCOUNT`
   - **Value:** Paste the ENTIRE JSON content (from `{` to `}`)

### Step 2: Deploy the Edge Function

```bash
cd /home/umesh/UserData/FlutterDartProjects/campus_connect_fl
supabase functions deploy send-notification
```

### Step 3: Test It!

The function is now ready to send FCM v1 notifications!

## 📋 Complete Deployment Checklist

- [ ] Downloaded service account JSON from Firebase
- [ ] Added FIREBASE_SERVICE_ACCOUNT to Supabase secrets
- [ ] Deployed Edge Function: `supabase functions deploy send-notification`
- [ ] Run COMPLETE_BROADCAST_FIX.sql in Supabase
- [ ] Rebuild Flutter app: `flutter pub get && flutter run`
- [ ] Test sending notification from app

## 🧪 Testing

### Test 1: From Firebase Console
1. Firebase Console → Cloud Messaging → "Send your first message"
2. Notification title: "Test"
3. Notification text: "Testing FCM v1"
4. Target: Topic = `all_users`
5. Send!

### Test 2: From Your App
1. Login as faculty
2. Go to Notifications
3. Click "Announce"
4. Send test notification
5. Check logs:
   ```
   📢 Calling Supabase Edge Function...
   📢 Supabase response: {success: true}
   📢 ✅ Broadcast complete!
   ```

## 🔒 Security Best Practices

**DO:**
- ✅ Keep service account JSON secret
- ✅ Store in Supabase secrets (encrypted)
- ✅ Never commit to git

**DON'T:**
- ❌ Share service account JSON publicly
- ❌ Commit to GitHub
- ❌ Include in app code

## 💰 Cost

**Everything is FREE:**
- Firebase HTTP v1 API: FREE
- FCM push notifications: FREE (unlimited)
- Supabase Edge Functions: FREE (500K/month)
- OAuth 2.0 tokens: FREE

**Your usage: $0/month** ✅

## 🆘 Troubleshooting

### Issue: "FIREBASE_SERVICE_ACCOUNT not set"
**Solution:** Make sure you added the secret in Supabase Dashboard

### Issue: "Invalid credentials"
**Solution:** 
- Check you copied the ENTIRE JSON (including `{` and `}`)
- Make sure there are no extra spaces or line breaks

### Issue: "Permission denied"
**Solution:**
- Regenerate service account key in Firebase
- Make sure using the correct project

## 📞 Quick Links

- Firebase Service Accounts: https://console.firebase.google.com/project/campus-connect-23fae/settings/serviceaccounts/adminsdk
- Supabase Edge Functions: https://app.supabase.com/project/_/functions
- FCM Documentation: https://firebase.google.com/docs/cloud-messaging/migrate-v1

---

**Ready? Follow these steps:**

1. Download service account JSON from Firebase
2. Add to Supabase as FIREBASE_SERVICE_ACCOUNT secret
3. Deploy: `supabase functions deploy send-notification`
4. Test!

🚀 You're using the modern, recommended FCM API now!
