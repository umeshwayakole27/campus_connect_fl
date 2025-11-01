# FIREBASE CLOUD MESSAGING - Complete Implementation Guide

## Why Use Firebase Instead?

✅ **Push notifications work even when app is closed**
✅ **No complex RLS policies to manage**
✅ **Battery efficient (no polling)**
✅ **Industry standard - used by millions of apps**
✅ **Supports topic-based broadcasting**
✅ **Offline message queuing**

## Architecture: Hybrid Approach (Best of Both Worlds)

```
Faculty Sends Notification
    ↓
[Firebase FCM] → Push notification to all devices (instant!)
    +
[Supabase DB] → Store notification history (for inbox)
```

## Implementation Steps

### Step 1: Setup Firebase Backend (Cloud Functions)

You need a backend to send FCM messages. Two options:

#### Option A: Firebase Cloud Functions (Recommended)
```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendBroadcastNotification = functions.https.onCall(async (data, context) => {
  // Verify caller is faculty
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  }
  
  const {title, message, type} = data;
  
  // Send to topic 'all_users'
  const payload = {
    notification: {
      title: title,
      body: message,
    },
    data: {
      type: type,
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
    },
  };
  
  await admin.messaging().sendToTopic('all_users', payload);
  
  return {success: true, message: 'Notification sent'};
});
```

#### Option B: Use Supabase Edge Functions
```typescript
// supabase/functions/send-notification/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

serve(async (req) => {
  const {title, message, type} = await req.json()
  
  // Call Firebase Admin SDK
  const response = await fetch('https://fcm.googleapis.com/fcm/send', {
    method: 'POST',
    headers: {
      'Authorization': `key=YOUR_SERVER_KEY`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      to: '/topics/all_users',
      notification: {title, body: message},
      data: {type}
    })
  })
  
  return new Response(JSON.stringify({success: true}))
})
```

### Step 2: Update Flutter App

The code is already partially there! We just need to:

1. **Save FCM token when user logs in**
2. **Subscribe to "all_users" topic**
3. **Call Firebase Cloud Function for broadcasting**

### Step 3: Database Setup

Run `setup_fcm_tokens.sql` to create the tokens table.

## Simplified Broadcast Flow

### Current (Database Only - Broken)
```
1. Faculty → broadcastNotification()
2. Query users table (RLS blocks!) → 0 users
3. Insert 0 notifications
4. Nothing happens ❌
```

### With Firebase (Works!)
```
1. Faculty → broadcastNotification()
2. Call Firebase Cloud Function
3. Firebase → Sends to topic "all_users"
4. All devices get push notification ✅
5. Also save to database for history
```

## Topic-Based vs Token-Based

### Topic-Based (Simpler - Recommended)
```dart
// When user logs in
await FirebaseMessaging.instance.subscribeToTopic('all_users');

// Faculty broadcasts
// Cloud Function sends to topic 'all_users'
// All subscribed devices get notification
```

**Pros:**
- ✅ Simple - no need to store tokens
- ✅ No RLS issues
- ✅ Automatic scaling

**Cons:**
- ⚠️ Can't track individual delivery
- ⚠️ All-or-nothing (can't exclude users)

### Token-Based (More Control)
```dart
// Save token to database
final token = await FirebaseMessaging.instance.getToken();
await repository.saveFCMToken(userId, token, 'android');

// Faculty broadcasts
// Cloud Function gets all tokens from DB
// Sends to each token individually
```

**Pros:**
- ✅ Track delivery per user
- ✅ Can exclude specific users
- ✅ More control

**Cons:**
- ❌ Need to store/manage tokens
- ❌ Token refresh handling
- ❌ RLS policies needed

## Quick Setup (Topic-Based)

### 1. Update FCM Service Initialization
Already done! Your app subscribes to 'all_users' topic on init.

### 2. Create Firebase Cloud Function
```bash
cd functions
npm install firebase-functions firebase-admin
```

### 3. Deploy
```bash
firebase deploy --only functions
```

### 4. Update Dart Code
```dart
// In notification_repository.dart
Future<void> broadcastNotification({
  required String type,
  required String title,
  required String message,
}) async {
  // Call Firebase Cloud Function
  final callable = FirebaseFunctions.instance.httpsCallable('sendBroadcastNotification');
  await callable.call({
    'title': title,
    'message': message,
    'type': type,
  });
  
  // Also save to database for history
  // (existing code)
}
```

## Testing

1. **Test topic subscription:**
```bash
# Send test from Firebase Console
Firebase Console → Cloud Messaging → Send test → Topic: all_users
```

2. **Test from app:**
```dart
// Faculty sends notification
// Watch logs: Should see FCM delivery logs
```

## Migration Plan

### Phase 1: Add Firebase (Quick Win)
- Set up Cloud Function
- Update broadcast to use Firebase topics
- Keep database for history
- **Result:** Notifications work instantly!

### Phase 2: Cleanup (Optional)
- Remove complex RLS policies
- Simplify database schema
- **Result:** Simpler, more maintainable code

## Cost

Firebase FCM is **FREE** up to:
- Unlimited messages on Android/iOS
- Paid only for advanced features

Supabase is also generous on free tier.

## Recommendation

**Use Firebase FCM with topics!**

1. ✅ Simpler than fixing RLS
2. ✅ Industry-standard solution
3. ✅ Works even when app is closed
4. ✅ Your app already has FCM setup
5. ✅ Just need to add the Cloud Function

Would you like me to create the complete Firebase Cloud Function code for you?
