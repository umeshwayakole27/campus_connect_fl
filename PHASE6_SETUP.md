# Phase 6: Search & Notifications - Setup Guide

## Overview

Phase 6 implements global search functionality and push notifications for the Campus Connect app.

---

## Features Implemented

### 1. Global Search
- Search across events, faculty, and campus locations
- Real-time search with debouncing
- Search history persistence
- Category filtering
- Results grouped by type
- Quick navigation to details

### 2. Push Notifications
- Firebase Cloud Messaging integration
- Event notifications
- Announcement notifications
- In-app notification center
- Mark as read/unread
- Notification preferences
- Badge counts

---

## Firebase Setup (Required for Notifications)

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Enter project name: "Campus Connect"
4. Enable Google Analytics (optional)
5. Click "Create project"

### Step 2: Add Android App

1. In Firebase console, click Android icon
2. Enter package name: `com.campus_connect.geca`
3. Enter app nickname: "Campus Connect Android"
4. Download `google-services.json`
5. Place file in `android/app/` directory

### Step 3: Add iOS App (Optional)

1. In Firebase console, click iOS icon
2. Enter bundle ID: `com.campusConnect.geca`
3. Download `GoogleService-Info.plist`
4. Place in `ios/Runner/` directory

### Step 4: Configure FlutterFire

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (run from project root)
flutterfire configure
```

This will:
- Create `lib/firebase_options.dart`
- Link your Firebase project
- Configure all platforms

### Step 5: Enable Cloud Messaging

1. In Firebase Console, go to "Cloud Messaging"
2. Click "Get Started" (if first time)
3. No additional setup needed for now

---

## Database Updates

### Notifications Table (Already exists)

The notifications table schema:
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  event_id UUID REFERENCES events(id),
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  sent_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  read BOOLEAN DEFAULT FALSE
);
```

### Add Title Column (If Missing)

```sql
-- Add title column if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'notifications' AND column_name = 'title'
  ) THEN
    ALTER TABLE notifications ADD COLUMN title TEXT;
    UPDATE notifications SET title = 'Notification' WHERE title IS NULL;
    ALTER TABLE notifications ALTER COLUMN title SET NOT NULL;
  END IF;
END $$;
```

### RLS Policies for Notifications

```sql
-- Enable RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Users can view their own notifications
CREATE POLICY "Users can view own notifications"
ON notifications FOR SELECT
USING (auth.uid() = user_id);

-- Faculty can create notifications
CREATE POLICY "Faculty can create notifications"
ON notifications FOR INSERT
WITH CHECK (
  auth.uid() IN (SELECT id FROM users WHERE role = 'faculty')
);

-- Users can update their own notifications (mark as read)
CREATE POLICY "Users can update own notifications"
ON notifications FOR UPDATE
USING (auth.uid() = user_id);

-- Faculty can delete notifications they created
CREATE POLICY "Faculty can delete notifications"
ON notifications FOR DELETE
USING (
  auth.uid() IN (
    SELECT e.created_by FROM events e WHERE e.id = event_id
  )
);
```

### Create Search History Table

```sql
-- Drop existing table if any
DROP TABLE IF EXISTS search_history CASCADE;

-- Create search history table
CREATE TABLE search_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) NOT NULL,
  query TEXT NOT NULL,
  category TEXT,
  searched_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Enable RLS
ALTER TABLE search_history ENABLE ROW LEVEL SECURITY;

-- Users can view their own search history
CREATE POLICY "Users can view own search history"
ON search_history FOR SELECT
USING (auth.uid() = user_id);

-- Users can insert their own search history
CREATE POLICY "Users can insert own search history"
ON search_history FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Users can delete their own search history
CREATE POLICY "Users can delete own search history"
ON search_history FOR DELETE
USING (auth.uid() = user_id);

-- Create index for performance
CREATE INDEX idx_search_history_user_id ON search_history(user_id);
CREATE INDEX idx_search_history_searched_at ON search_history(searched_at DESC);
```

---

## Android Configuration

### Update `android/app/build.gradle`

Add at the bottom (after dependencies):
```gradle
apply plugin: 'com.google.gms.google-services'
```

### Update `android/build.gradle`

Add to dependencies:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

### Update `android/app/src/main/AndroidManifest.xml`

Add notification permissions and receiver:
```xml
<manifest>
    <!-- Add permissions -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    
    <application>
        <!-- Add notification metadata -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="campus_connect_channel" />
            
        <!-- Optional: Default notification icon -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@mipmap/ic_launcher" />
    </application>
</manifest>
```

---

## iOS Configuration (Optional)

### Update `ios/Runner/Info.plist`

Add notification permissions:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### Update `ios/Runner/AppDelegate.swift`

```swift
import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

---

## Testing

### Test Search Functionality

1. Open app and navigate to Search tab
2. Search for events: "workshop"
3. Search for faculty: "kumar"
4. Search for locations: "library"
5. Verify search history is saved
6. Test category filters
7. Clear search history

### Test Notifications

1. **Setup Test Data**:
   ```sql
   -- Insert test notification
   INSERT INTO notifications (user_id, type, title, message, read)
   VALUES (
     '<your-user-id>',
     'announcement',
     'Welcome to Campus Connect',
     'Explore events, faculty, and campus locations!',
     false
   );
   ```

2. **Test In-App Notifications**:
   - Open Notifications tab
   - Verify notification appears
   - Tap to mark as read
   - Check badge count updates
   - Test "Mark all as read"
   - Test delete functionality

3. **Test Push Notifications** (requires device):
   - Send test notification from Firebase Console
   - Go to Cloud Messaging → Test
   - Enter FCM token (see app logs)
   - Send notification
   - Verify notification appears

### Test Firebase Integration

1. Run the app
2. Check logs for: "FCM Token: ..."
3. Copy the token
4. Go to Firebase Console → Cloud Messaging
5. Click "Send test message"
6. Paste token and send
7. Notification should appear on device

---

## Notification Types

### Event Notifications
- New event created
- Event updated
- Event starting soon (1 hour before)
- Event cancelled

### Announcement Notifications
- Faculty announcements
- Campus-wide alerts
- Important updates

### System Notifications
- Welcome message (first login)
- Profile completion reminders
- Feature announcements

---

## Search Categories

1. **Events**: Search by title, description, location
2. **Faculty**: Search by name, department, designation
3. **Locations**: Search by name, building code, description
4. **All**: Search across all categories

---

## Troubleshooting

### Firebase not initialized
**Error**: `Firebase not initialized`
**Fix**: 
1. Run `flutterfire configure`
2. Ensure `firebase_options.dart` exists
3. Check `google-services.json` is in `android/app/`

### Notifications not appearing
**Error**: Notifications don't show up
**Fix**:
1. Check notification permissions granted
2. Verify FCM token is generated (check logs)
3. Test with Firebase Console test message
4. Check Android notification channel created

### Search not working
**Error**: Search returns no results
**Fix**:
1. Verify data exists in Supabase tables
2. Check RLS policies allow read access
3. Test search query in Supabase SQL editor
4. Check network connectivity

### Permission denied
**Error**: `permission denied for table search_history`
**Fix**:
1. Ensure RLS policies are created
2. Check user is authenticated
3. Verify user_id matches auth.uid()

---

## File Structure

```
lib/features/
├── search/
│   ├── data/
│   │   └── search_repository.dart
│   └── presentation/
│       ├── search_provider.dart
│       └── search_screen.dart
│
└── notifications/
    ├── data/
    │   └── notification_repository.dart
    ├── services/
    │   └── fcm_service.dart
    └── presentation/
        ├── notification_provider.dart
        └── notifications_screen.dart
```

---

## Next Steps

After Phase 6 completion:
1. Test all features thoroughly
2. Verify Firebase integration works
3. Test on both Android and iOS (if applicable)
4. Move to Phase 7: UI/UX Polish
5. Implement advanced features (optional):
   - Scheduled notifications
   - Notification grouping
   - Rich notifications with images
   - Advanced search filters
   - Search suggestions/autocomplete

---

## Dependencies Added

Already in pubspec.yaml:
```yaml
firebase_core: ^3.3.0
firebase_messaging: ^15.0.4
flutter_local_notifications: ^17.2.2
```

Additional (if needed):
```yaml
shared_preferences: ^2.2.3  # For search history persistence
```

---

## Security Considerations

1. **RLS Policies**: Ensure users can only see their own notifications
2. **Search History**: Private to each user
3. **FCM Tokens**: Store securely, don't expose in logs
4. **Notification Content**: Sanitize before sending
5. **Rate Limiting**: Prevent notification spam

---

**Phase 6 Complete**: Global Search and Push Notifications ready! 🎉
