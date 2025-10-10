# 🚀 Quick Start Guide - Campus Connect

Get your Campus Connect app up and running in minutes!

## Prerequisites Checklist

- [ ] Flutter installed (version ^3.9.2)
- [ ] Code editor (VS Code, Android Studio, or IntelliJ)
- [ ] Git installed
- [ ] Supabase account (free tier is fine)
- [ ] Google Cloud account (for Maps API)
- [ ] Firebase account (optional, for notifications)

---

## Step-by-Step Setup

### 1. Clone & Install (5 minutes)

```bash
# Navigate to your projects folder
cd ~/projects

# Clone the repository
git clone <your-repo-url>
cd campus_connect_fl

# Install dependencies
flutter pub get

# Generate model code
dart run build_runner build --delete-conflicting-outputs
```

### 2. Supabase Setup (10 minutes)

#### Create Supabase Project
1. Go to https://supabase.com
2. Click "New Project"
3. Choose organization or create new
4. Fill in:
   - **Name**: Campus Connect
   - **Database Password**: (save this!)
   - **Region**: Choose closest to you
5. Click "Create new project"
6. Wait ~2 minutes for provisioning

#### Get API Credentials
1. In dashboard, go to **Settings** → **API**
2. Copy:
   - **Project URL** (e.g., https://xxxxx.supabase.co)
   - **anon/public key**

#### Update .env File
```bash
# Open .env and paste your credentials
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
GOOGLE_MAPS_API_KEY=your-google-maps-key
```

### 3. Database Setup (10 minutes)

#### Run SQL Scripts
1. In Supabase dashboard, go to **SQL Editor**
2. Click **New Query**
3. Copy and run each script from `SUPABASE_SETUP.md`:

**Step 1: Enable UUID**
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

**Step 2: Create Tables** (copy from SUPABASE_SETUP.md)
- users table
- events table
- faculty table
- campus_locations table
- notifications table

**Step 3: Enable RLS**
```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE faculty ENABLE ROW LEVEL SECURITY;
ALTER TABLE campus_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
```

**Step 4: Add RLS Policies** (copy all policies from SUPABASE_SETUP.md)

**Step 5: Add Triggers** (copy trigger functions from SUPABASE_SETUP.md)

### 4. Google Maps Setup (5 minutes)

#### Get API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create new project or select existing
3. Enable **Maps SDK for Android** and **Maps SDK for iOS**
4. Create API key under **Credentials**
5. Add to your `.env` file

#### Configure Android
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest>
    <application>
        <!-- Add inside application tag -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="${GOOGLE_MAPS_API_KEY}"/>
    </application>
</manifest>
```

#### Configure iOS
Edit `ios/Runner/AppDelegate.swift`:
```swift
import GoogleMaps

@main
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

### 5. Firebase Setup (Optional - 10 minutes)

For push notifications:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure

# Follow prompts to:
# 1. Select/create Firebase project
# 2. Choose platforms (iOS, Android)
# 3. This will create firebase_options.dart
```

### 6. Run the App! 🎉

```bash
# Check connected devices
flutter devices

# Run on connected device
flutter run

# Or specify device
flutter run -d chrome          # Web
flutter run -d <device-id>     # Mobile
```

---

## ⚡ Quick Commands

```bash
# Install dependencies
flutter pub get

# Generate code
dart run build_runner build --delete-conflicting-outputs

# Run app
flutter run

# Run tests
flutter test

# Check for issues
flutter analyze

# Clean build
flutter clean && flutter pub get

# Update dependencies
flutter pub upgrade
```

---

## 🔍 Verify Everything Works

### Checklist:
- [ ] App launches without errors
- [ ] You see the splash screen
- [ ] Supabase connection established (check logs)
- [ ] No red errors in console

### Expected Console Output:
```
[INFO] Supabase initialized successfully
[INFO] Campus Connect initialized successfully
```

---

## 🐛 Troubleshooting

### Problem: "SUPABASE_URL not found"
**Solution**: Check .env file exists and has correct format

### Problem: "Failed to initialize Supabase"
**Solution**: Verify URL and anon key are correct, check internet connection

### Problem: Build fails on Android
**Solution**: 
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Problem: Build fails on iOS
**Solution**:
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

### Problem: "Target of URI hasn't been generated"
**Solution**:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 📱 Test Account Setup

Once the app runs, you'll need test accounts. In Phase 2, you'll create:

**Student Account**:
- Email: student@test.com
- Password: Test123!
- Role: student

**Faculty Account**:
- Email: faculty@test.com
- Password: Test123!
- Role: faculty

---

## 🎯 What's Next?

After setup is complete:
1. ✅ Verify app runs successfully
2. ✅ Check all services are initialized
3. 📖 Read through the codebase structure
4. 🔜 Proceed to Phase 2 (Authentication)

---

## 📚 Useful Links

- **Project Docs**: See README.md
- **Supabase Guide**: See SUPABASE_SETUP.md
- **Progress Tracker**: See progress.md
- **Phase 1 Summary**: See PHASE1_SUMMARY.md

---

## 💡 Tips

1. **Always check .env file first** when things don't work
2. **Run flutter clean** if you have weird build issues
3. **Check Supabase dashboard** for database issues
4. **Use Flutter DevTools** for debugging
5. **Check progress.md** to track where you are

---

## ⏱️ Time Estimate

- Initial setup: ~5 minutes
- Supabase configuration: ~10 minutes
- Database setup: ~10 minutes
- Google Maps: ~5 minutes
- Firebase (optional): ~10 minutes
- Testing: ~5 minutes

**Total: ~30-45 minutes**

---

## 🎉 Success!

If you can run the app and see the splash screen with no errors, you're ready to proceed to Phase 2!

**Next**: Authentication & User Management

---

## 📞 Need Help?

1. Check error messages carefully
2. Review SUPABASE_SETUP.md
3. Read Flutter documentation
4. Check Supabase documentation
5. Review progress.md for context

---

**Happy Coding! 🚀**
