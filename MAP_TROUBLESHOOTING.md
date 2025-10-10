# Google Maps Troubleshooting Guide

## Issue: Map Not Displaying (Only Google Logo Visible)

### Current Status
- ✅ Google Maps API key added to AndroidManifest.xml
- ✅ Campus center coordinates updated to GECA (19.8680502, 75.3241057)
- ✅ App builds and runs successfully
- ❌ Map tiles not loading (blank screen with Google logo only)

---

## Root Causes and Solutions

### 1. API Key Not Enabled for Required Services

#### Problem:
The Google Maps API key needs to be enabled for specific Google services.

#### Solution:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Navigate to **APIs & Services > Library**
4. Enable the following APIs:
   - ✅ **Maps SDK for Android** (REQUIRED)
   - ✅ **Maps SDK for iOS** (if building for iOS)
   - ⚠️ Geocoding API (optional - for reverse geocoding)
   - ⚠️ Places API (optional - for place search)
   - ⚠️ Directions API (optional - for navigation)

#### Commands to Check:
```bash
# Verify which APIs are enabled in your project
gcloud services list --enabled --project YOUR_PROJECT_ID
```

---

### 2. API Key Restrictions Not Configured

#### Problem:
API key may have incorrect or missing application restrictions.

#### Solution:
1. Go to **APIs & Services > Credentials**
2. Click on your API key
3. Under **Application restrictions**:
   - Select "Android apps"
   - Click "Add an item"
   - Package name: `com.campus_connect.geca`
   - SHA-1 certificate fingerprint: (see below)

#### Get SHA-1 Certificate Fingerprint:
```bash
# Debug certificate (for development)
cd android
./gradlew signingReport

# Look for SHA-1 under "Variant: debug"
# Example output:
# SHA1: 3B:4C:8F:2E:...
```

#### Add SHA-1 to Google Cloud:
1. Copy the SHA-1 from debug variant
2. Paste it in Google Cloud Console API key restrictions
3. Click "Save"
4. Wait 5-10 minutes for changes to propagate

---

### 3. API Key Quota Exceeded

#### Problem:
Free tier quota may be exceeded or billing not enabled.

#### Solution:
1. Check quota usage:
   - Go to **APIs & Services > Dashboard**
   - Select **Maps SDK for Android**
   - Check usage graph

2. Enable billing (if not already):
   - Go to **Billing**
   - Link a billing account
   - Google provides $200/month free credit

---

### 4. Network/Connectivity Issues

#### Problem:
Device may not have internet or network permissions.

#### Solution:
1. Verify internet permission in `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

2. Check device connectivity:
   - Ensure WiFi/Mobile data is ON
   - Try opening a browser on the device

3. Check for firewall/proxy restrictions

---

### 5. Location Permissions Not Granted

#### Problem:
Location permissions may be denied.

#### Solution:
1. Verify permissions in `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

2. Grant permissions manually:
   - Go to **Settings > Apps > Campus Connect > Permissions**
   - Enable Location permission

---

### 6. Invalid or Expired API Key

#### Problem:
API key may be invalid, deleted, or regenerated.

#### Solution:
1. Verify your API key in `.env` file matches Google Cloud Console
2. If key was regenerated:
   - Update `.env` file
   - Update `AndroidManifest.xml`
   - Rebuild app: `flutter clean && flutter run`

---

### 7. Supabase Data Not Loaded

#### Problem:
Campus locations may not be in the database.

#### Solution:
1. Check Supabase dashboard:
   - Navigate to **Table Editor**
   - Open `campus_locations` table
   - Verify 14 GECA locations exist

2. If data is missing, run the SQL from `PHASE3_SETUP.md`:
```sql
INSERT INTO campus_locations (name, description, building_code, lat, lng, category, floor_info) VALUES
  ('Main Administrative Building', 'Principal office, administrative offices and main reception', 'ADMIN', 19.868473, 75.323921, 'admin', '1st floor'),
  -- ... (rest of locations)
```

---

## Quick Verification Checklist

### Before Testing:
- [ ] Google Cloud project created
- [ ] Maps SDK for Android enabled
- [ ] API key created and copied
- [ ] API key added to both `.env` and `AndroidManifest.xml`
- [ ] Package name restriction: `com.campus_connect.geca`
- [ ] SHA-1 certificate added (debug)
- [ ] Billing enabled (or free trial active)
- [ ] App rebuilt: `flutter clean && flutter run`

### During Testing:
- [ ] Internet connection active on device
- [ ] Location permission granted in app settings
- [ ] Supabase connection working (auth works)
- [ ] Campus locations data exists in Supabase
- [ ] No errors in `flutter run` console

### Expected Behavior:
- [ ] Map loads with satellite/street view
- [ ] Map centers on GECA campus (19.8680502, 75.3241057)
- [ ] 14 colored markers visible on map
- [ ] Category filter chips visible above map
- [ ] Tapping marker shows location details
- [ ] "Center on campus" button works

---

## Debugging Commands

### Check Current Configuration:
```bash
# View API key in .env
cat .env | grep GOOGLE_MAPS_API_KEY

# View API key in AndroidManifest
cat android/app/src/main/AndroidManifest.xml | grep -A 2 "com.google.android.geo.API_KEY"

# Get debug SHA-1
cd android && ./gradlew signingReport | grep SHA1
```

### Monitor App Logs:
```bash
# Run with verbose logging
flutter run -v

# Filter for Google Maps logs
flutter run 2>&1 | grep -i "maps\|google"

# Check ADB logs
adb logcat | grep -i "maps\|google"
```

### Test API Key Directly:
```bash
# Test API key with curl (replace YOUR_API_KEY)
curl "https://maps.googleapis.com/maps/api/staticmap?center=19.8680502,75.3241057&zoom=15&size=600x300&maptype=roadmap&key=YOUR_API_KEY"

# Should return image data, not an error
```

---

## Common Error Messages

### "Error: MapsInitializationException"
- **Cause**: API key not configured correctly
- **Fix**: Verify API key in AndroidManifest.xml

### "Error: ApiException: This API key is not authorized"
- **Cause**: Package name or SHA-1 restrictions mismatch
- **Fix**: Update API key restrictions in Google Cloud Console

### "Error: OVER_QUERY_LIMIT"
- **Cause**: API quota exceeded
- **Fix**: Enable billing or wait for quota reset

### "Error: REQUEST_DENIED"
- **Cause**: Maps SDK for Android not enabled
- **Fix**: Enable in Google Cloud Console > APIs & Services > Library

### Blank map with "For development purposes only" watermark
- **Cause**: Using incorrect API key or no API key
- **Fix**: Add valid API key to AndroidManifest.xml

---

## Alternative Testing Method

If map still doesn't work, test with a simple standalone example:

### Create Test App:
```bash
flutter create map_test
cd map_test
flutter pub add google_maps_flutter
```

### Update `lib/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Map Test')),
        body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(19.8680502, 75.3241057),
            zoom: 15,
          ),
        ),
      ),
    );
  }
}
```

### Add API key to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY"/>
```

### Run:
```bash
flutter run
```

If this works, the issue is in Campus Connect code. If it doesn't, the issue is with Google Cloud setup.

---

## Support Resources

- [Google Maps Platform Documentation](https://developers.google.com/maps/documentation/android-sdk/overview)
- [API Key Best Practices](https://developers.google.com/maps/api-security-best-practices)
- [Troubleshooting Guide](https://developers.google.com/maps/documentation/android-sdk/troubleshooting)
- [Stack Overflow - google-maps-flutter](https://stackoverflow.com/questions/tagged/google-maps-flutter)

---

## Next Steps After Map Fix

Once the map is working:
1. ✅ Mark Phase 3 as complete in `progress.md`
2. ✅ Update `PHASE3_SUMMARY.md` with success details
3. ✅ Proceed to Phase 4: Event Management Module
4. ✅ Test all map features (markers, filtering, navigation)
5. ✅ Document any performance optimizations needed

---

**Last Updated**: 2024
**Status**: Awaiting Google Cloud configuration verification
