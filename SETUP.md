# Campus Connect - Complete Setup Guide

This guide provides detailed, step-by-step instructions for setting up Campus Connect from scratch on a new computer.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Flutter Setup](#flutter-setup)
3. [Supabase Setup](#supabase-setup)
4. [Firebase Setup](#firebase-setup)
5. [Google Maps Setup](#google-maps-setup)
6. [Project Configuration](#project-configuration)
7. [Database Setup](#database-setup)
8. [Running the App](#running-the-app)

---

## Prerequisites

### Required Software
- **Operating System**: Windows 10/11, macOS 10.14+, or Linux (Ubuntu 18.04+)
- **Git**: Version control system
- **Android Studio** (for Android development)
- **Xcode** (for iOS development - macOS only)
- **VS Code** or **Android Studio** (recommended IDEs)

### Required Accounts
- Google Cloud Platform account (for Google Maps API)
- Supabase account (for backend database)
- Firebase account (for push notifications)

---

## Flutter Setup

### Step 1: Install Flutter SDK

#### Windows:
```bash
# Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
# Extract to C:\src\flutter
# Add to PATH: C:\src\flutter\bin

# Verify installation
flutter doctor
```

#### macOS:
```bash
# Using Homebrew
brew install flutter

# Or download from https://flutter.dev/docs/get-started/install/macos

# Verify installation
flutter doctor
```

#### Linux:
```bash
# Download Flutter SDK
cd ~/development
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.x.x-stable.tar.xz
tar xf flutter_linux_3.x.x-stable.tar.xz

# Add to PATH in ~/.bashrc or ~/.zshrc
export PATH="$PATH:$HOME/development/flutter/bin"

# Verify installation
flutter doctor
```

### Step 2: Install Dependencies

```bash
# Accept Android licenses
flutter doctor --android-licenses

# Install Android Studio
# Download from https://developer.android.com/studio

# Install Android SDK Command-line Tools
# In Android Studio: Settings → Appearance & Behavior → System Settings → Android SDK → SDK Tools
```

### Step 3: Install Flutter Extensions

**For VS Code:**
- Install "Flutter" extension by Dart Code
- Install "Dart" extension by Dart Code

**For Android Studio:**
- Install "Flutter" plugin
- Install "Dart" plugin

---

## Supabase Setup

### Step 1: Create Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Sign up or log in
3. Click "New Project"
4. Fill in project details:
   - **Project Name**: `campus-connect`
   - **Database Password**: Create a strong password (save this!)
   - **Region**: Choose closest to your users
   - **Pricing Plan**: Free tier is sufficient for development

5. Wait 2-3 minutes for project creation

### Step 2: Get Supabase Credentials

1. In your Supabase project dashboard, click "Settings" (gear icon)
2. Navigate to "API" section
3. Copy the following:
   - **Project URL**: `https://xxxxxxxxxxxxx.supabase.co`
   - **Anon Public Key**: `eyJhbGc...` (long string)

### Step 3: Configure Supabase Authentication

1. Go to "Authentication" → "Providers"
2. Enable **Email** provider
3. Configure settings:
   - ✅ Enable Email Confirmations (Optional - disable for development)
   - ✅ Enable Email provider
   - Set "Site URL" to your app URL (or `http://localhost:3000` for development)

### Step 4: Enable Realtime (Optional)

1. Go to "Database" → "Replication"
2. Enable replication for tables that need real-time updates:
   - `events`
   - `notifications`

---

## Database Setup

### Step 1: Create Database Tables

1. In Supabase dashboard, go to "SQL Editor"
2. Click "New Query"
3. Copy and paste the following SQL:

```sql
-- Create users table (extends Supabase auth.users)
CREATE TABLE public.users (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('student', 'faculty')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create faculty profiles table
CREATE TABLE public.faculty (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  user_name TEXT NOT NULL,
  designation TEXT,
  department TEXT NOT NULL,
  office TEXT,
  office_hours TEXT,
  email TEXT,
  phone TEXT,
  profile_image_url TEXT,
  bio TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create campus locations table
CREATE TABLE public.campus_locations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  building_code TEXT,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  description TEXT,
  facilities TEXT[],
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create events table
CREATE TABLE public.events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  time TIMESTAMP WITH TIME ZONE NOT NULL,
  location TEXT,
  location_id UUID REFERENCES public.campus_locations(id),
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create notifications table
CREATE TABLE public.notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'general',
  data JSONB,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create FCM tokens table for push notifications
CREATE TABLE public.fcm_tokens (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  token TEXT NOT NULL UNIQUE,
  device_type TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create search history table
CREATE TABLE public.search_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  query TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create indexes for better performance
CREATE INDEX idx_events_time ON public.events(time);
CREATE INDEX idx_events_created_by ON public.events(created_by);
CREATE INDEX idx_faculty_department ON public.faculty(department);
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_is_read ON public.notifications(is_read);
CREATE INDEX idx_fcm_tokens_user_id ON public.fcm_tokens(user_id);
CREATE INDEX idx_search_history_user_id ON public.search_history(user_id);
```

4. Click "Run" to execute the query

### Step 2: Set Up Row Level Security (RLS)

```sql
-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.faculty ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campus_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fcm_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.search_history ENABLE ROW LEVEL SECURITY;

-- Users table policies
CREATE POLICY "Users can view all users" ON public.users FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON public.users FOR UPDATE USING (auth.uid() = id);

-- Faculty table policies
CREATE POLICY "Everyone can view faculty" ON public.faculty FOR SELECT USING (true);
CREATE POLICY "Faculty can update own profile" ON public.faculty FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Faculty can insert own profile" ON public.faculty FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Campus locations policies
CREATE POLICY "Everyone can view locations" ON public.campus_locations FOR SELECT USING (true);

-- Events table policies
CREATE POLICY "Everyone can view events" ON public.events FOR SELECT USING (true);
CREATE POLICY "Faculty can create events" ON public.events FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'faculty'
  )
);
CREATE POLICY "Faculty can update own events" ON public.events FOR UPDATE USING (
  auth.uid() = created_by
);
CREATE POLICY "Faculty can delete own events" ON public.events FOR DELETE USING (
  auth.uid() = created_by
);

-- Notifications policies
CREATE POLICY "Users can view own notifications" ON public.notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own notifications" ON public.notifications FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Faculty can create notifications" ON public.notifications FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'faculty'
  )
);

-- FCM tokens policies
CREATE POLICY "Users can manage own tokens" ON public.fcm_tokens FOR ALL USING (auth.uid() = user_id);

-- Search history policies
CREATE POLICY "Users can manage own search history" ON public.search_history FOR ALL USING (auth.uid() = user_id);
```

### Step 3: Insert Sample Campus Locations

```sql
INSERT INTO public.campus_locations (name, building_code, latitude, longitude, description) VALUES
('Main Gate', 'GATE-1', 18.5204, 73.8567, 'Main entrance to campus'),
('Library', 'LIB', 18.5210, 73.8570, 'Central library with study rooms'),
('Computer Science Department', 'CS-DEPT', 18.5215, 73.8575, 'CS department building'),
('Engineering Block A', 'ENG-A', 18.5220, 73.8580, 'Engineering classrooms'),
('Cafeteria', 'CAF', 18.5225, 73.8585, 'Student cafeteria'),
('Auditorium', 'AUD', 18.5230, 73.8590, 'Main auditorium for events'),
('Sports Complex', 'SPORTS', 18.5235, 73.8595, 'Indoor and outdoor sports facilities'),
('Administrative Office', 'ADMIN', 18.5240, 73.8600, 'Main administrative building'),
('Hostel Block 1', 'HOST-1', 18.5245, 73.8605, 'Student hostel'),
('Parking Area', 'PARK', 18.5250, 73.8610, 'Vehicle parking');
```

### Step 4: Create Database Functions

```sql
-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc', NOW());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_faculty_updated_at BEFORE UPDATE ON public.faculty
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON public.events
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to broadcast notifications to all users (bypasses RLS)
CREATE OR REPLACE FUNCTION broadcast_notification_to_all_users(
  p_type TEXT,
  p_title TEXT,
  p_message TEXT,
  p_event_id UUID DEFAULT NULL
)
RETURNS SETOF notifications
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  INSERT INTO notifications (user_id, type, title, message, event_id, read)
  SELECT 
    id,
    p_type,
    p_title,
    p_message,
    p_event_id,
    false
  FROM users
  RETURNING *;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION broadcast_notification_to_all_users(TEXT, TEXT, TEXT, UUID) TO authenticated;
```

---

## Firebase Setup

### Step 1: Create Firebase Project

1. Go to [https://console.firebase.google.com](https://console.firebase.google.com)
2. Click "Add Project"
3. Enter project name: `campus-connect`
4. Disable Google Analytics (optional for development)
5. Click "Create Project"

### Step 2: Add Android App

1. In Firebase Console, click the **Android icon**
2. Register app:
   - **Android package name**: `com.campus_connect.geca` (or your package name)
   - **App nickname**: Campus Connect Android
   - Leave SHA-1 empty for now (required for Google Sign-In)
3. Download `google-services.json`
4. Place it in `android/app/` directory

### Step 3: Add iOS App (macOS only)

1. In Firebase Console, click the **iOS icon**
2. Register app:
   - **iOS bundle ID**: `com.campusConnect.geca` (or your bundle ID)
   - **App nickname**: Campus Connect iOS
3. Download `GoogleService-Info.plist`
4. Add it to your Xcode project

### Step 4: Enable Firebase Cloud Messaging (FCM)

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Navigate to **Cloud Messaging** tab
3. Under "Cloud Messaging API (Legacy)", enable the API
4. Copy the **Server Key** - you'll need this for sending notifications

### Step 5: Enable Firebase Cloud Messaging API (V1)

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select your Firebase project
3. Go to "APIs & Services" → "Library"
4. Search for "Firebase Cloud Messaging API"
5. Click "Enable"

### Step 6: Generate Service Account Key (for backend notifications)

1. In Firebase Console, go to **Project Settings** → **Service Accounts**
2. Click "Generate New Private Key"
3. Download the JSON file
4. Store securely (never commit to version control!)

---

## Google Maps Setup

### Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create new project or select existing Firebase project
3. Project name: `campus-connect`

### Step 2: Enable APIs

1. Go to "APIs & Services" → "Library"
2. Search and enable the following APIs:
   - **Maps SDK for Android**
   - **Maps SDK for iOS**
   - **Places API**
   - **Directions API**
   - **Geocoding API**

### Step 3: Create API Key

1. Go to "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "API Key"
3. Copy the API key (save this!)
4. Click "Restrict Key" (recommended)

### Step 4: Restrict API Key (Recommended)

**For Android:**
1. Click on your API key
2. Under "Application restrictions", select "Android apps"
3. Click "Add an item"
4. Enter:
   - **Package name**: `com.campus_connect.geca`
   - **SHA-1 certificate fingerprint**: (get from terminal)

Get SHA-1 fingerprint:
```bash
# For debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# For release keystore
keytool -list -v -keystore /path/to/your-release-key.jks -alias your-key-alias
```

**For iOS:**
1. Select "iOS apps"
2. Enter your iOS bundle ID: `com.campusConnect.geca`

### Step 5: Configure API Restrictions

1. Under "API restrictions", select "Restrict key"
2. Select the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API
   - Directions API
   - Geocoding API
3. Click "Save"

---

## Project Configuration

### Step 1: Clone Repository

```bash
git clone https://github.com/yourusername/campus_connect_fl.git
cd campus_connect_fl
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Create Environment File

Create a `.env` file in the project root:

```bash
# Supabase Configuration
SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Google Maps API Key
GOOGLE_MAPS_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

**Important**: Add `.env` to `.gitignore` to keep credentials secure!

### Step 4: Configure Android

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
  <application>
    <!-- Add Google Maps API Key -->
    <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="${GOOGLE_MAPS_API_KEY}"/>
  </application>

  <!-- Add permissions -->
  <uses-permission android:name="android.permission.INTERNET"/>
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
</manifest>
```

Edit `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        // Load Google Maps API key from .env
        manifestPlaceholders = [
            GOOGLE_MAPS_API_KEY: project.hasProperty('GOOGLE_MAPS_API_KEY') 
                ? project.property('GOOGLE_MAPS_API_KEY') 
                : System.getenv('GOOGLE_MAPS_API_KEY')
        ]
    }
}
```

### Step 5: Configure iOS (macOS only)

Edit `ios/Runner/AppDelegate.swift`:

```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

Edit `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location when open to show your position on the map.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to location to provide navigation features.</string>
```

---

## Running the App

### Step 1: Check Setup

```bash
flutter doctor -v
```

Ensure all checkmarks are green or at least one platform (Android/iOS) is ready.

### Step 2: Connect Device

**For Android:**
```bash
# Connect Android device via USB (enable Developer Options and USB Debugging)
# Or start Android emulator from Android Studio

# List devices
flutter devices
```

**For iOS (macOS only):**
```bash
# Connect iPhone via USB
# Or start iOS simulator

# List devices
flutter devices
```

### Step 3: Run the App

```bash
# Run on connected device
flutter run

# Run on specific device
flutter run -d <device-id>

# Run in release mode (optimized)
flutter run --release
```

### Step 4: Hot Reload

While app is running:
- Press `r` to hot reload
- Press `R` to hot restart
- Press `q` to quit

---

## Building for Production

### Android APK

```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS IPA (macOS only)

```bash
# Build IPA
flutter build ios --release

# Archive in Xcode for App Store submission
```

---

## Troubleshooting

### Common Issues

**Issue**: `google-services.json` not found
- **Solution**: Ensure file is in `android/app/` directory

**Issue**: Google Maps not showing
- **Solution**: Check API key is correct and APIs are enabled

**Issue**: Supabase connection error
- **Solution**: Verify SUPABASE_URL and SUPABASE_ANON_KEY in `.env`

**Issue**: Build fails on iOS
- **Solution**: Run `cd ios && pod install && cd ..`

**Issue**: Location permission denied
- **Solution**: Check permissions in AndroidManifest.xml and Info.plist

### Debug Commands

```bash
# Clean project
flutter clean

# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Analyze code
flutter analyze

# Run tests
flutter test
```

---

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Maps Documentation](https://developers.google.com/maps/documentation)

---

## Support

For issues or questions:
1. Check the [GitHub Issues](https://github.com/yourusername/campus_connect_fl/issues)
2. Read the documentation
3. Contact the development team

---

**Setup Complete!** 🎉

You should now have Campus Connect running on your device. Test all features:
- Register as a student and faculty
- Create events (faculty only)
- Navigate campus map
- Search for events and faculty
- Check notifications
