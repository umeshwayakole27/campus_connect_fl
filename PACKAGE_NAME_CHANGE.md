# Package Name Change - com.campus_connect.geca

## Summary

The application package name has been successfully changed from the default `com.example.campus_connect_fl` to **`com.campus_connect.geca`** for GECA (Government Engineering College) deployment.

---

## Changes Made

### Android Configuration

#### 1. Build Configuration (`android/app/build.gradle.kts`)
```kotlin
android {
    namespace = "com.campus_connect.geca"
    // ...
    defaultConfig {
        applicationId = "com.campus_connect.geca"
        // ...
    }
}
```

#### 2. MainActivity Package
- **Old Location**: `android/app/src/main/kotlin/com/example/campus_connect_fl/MainActivity.kt`
- **New Location**: `android/app/src/main/kotlin/com/campus_connect/geca/MainActivity.kt`
- **Package Declaration**: `package com.campus_connect.geca`

#### 3. Android Manifest (`android/app/src/main/AndroidManifest.xml`)
- Updated app label to "Campus Connect"
- Added Google Maps API Key meta-data
- Added location permissions:
  - `ACCESS_FINE_LOCATION`
  - `ACCESS_COARSE_LOCATION`
  - `INTERNET`

```xml
<application android:label="Campus Connect" ...>
    <!-- Google Maps API Key -->
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="${GOOGLE_MAPS_API_KEY}"/>
    ...
</application>
```

### iOS Configuration

#### Bundle Identifier (`ios/Runner.xcodeproj/project.pbxproj`)
- **Old**: `com.example.campusConnectFl`
- **New**: `com.campus_connect.geca`

All occurrences updated in:
- Debug configuration
- Profile configuration
- Release configuration
- Runner Tests configurations

### Project Configuration

#### pubspec.yaml
- **Description**: Updated to "Campus Connect - GECA Campus Navigation and Event Management App"
- **Package name**: Remains `campus_connect_fl` (Dart package name)

---

## File Structure Changes

### Before:
```
android/app/src/main/kotlin/
└── com/
    └── example/
        └── campus_connect_fl/
            └── MainActivity.kt
```

### After:
```
android/app/src/main/kotlin/
└── com/
    └── campus_connect/
        └── geca/
            └── MainActivity.kt
```

---

## Verification Steps

To verify the package name change worked correctly:

1. **Clean build**:
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Check Android package**:
   ```bash
   grep -r "com.campus_connect.geca" android/app/build.gradle.kts
   ```

3. **Check iOS bundle**:
   ```bash
   grep "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj
   ```

4. **Build and run**:
   ```bash
   flutter run
   ```

---

## Important Notes

### Google Maps API Key

The AndroidManifest.xml now includes a placeholder for Google Maps API key:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${GOOGLE_MAPS_API_KEY}"/>
```

**To configure**:
1. Get your Google Maps API key from Google Cloud Console
2. Add to `.env` file:
   ```
   GOOGLE_MAPS_API_KEY=your_actual_api_key_here
   ```

### Location Permissions

The app now requests location permissions for map functionality:
- Fine location (GPS)
- Coarse location (Network-based)

Users will be prompted to grant these permissions when using map features.

### Signing Configuration

For production release, you'll need to:
1. Generate a signing key
2. Update `android/app/build.gradle.kts` with signing config
3. Create `android/key.properties` file

---

## Testing Checklist

After package name change:

- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Test debug build: `flutter run`
- [ ] Test Android build: `flutter build apk`
- [ ] Test iOS build: `flutter build ios` (on macOS)
- [ ] Verify app installs with new package name
- [ ] Check app appears correctly in device settings
- [ ] Verify Google Maps integration (Phase 3)
- [ ] Test on physical device

---

## Troubleshooting

### Build Errors

If you encounter build errors:

```bash
# Clean everything
flutter clean
cd android && ./gradlew clean
cd ..

# Rebuild
flutter pub get
flutter run
```

### Old Package References

If old package name appears:
1. Search for `com.example` in project
2. Update any missed references
3. Clean and rebuild

### iOS Issues

If iOS build fails:
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

---

## Next Steps

1. ✅ Package name changed successfully
2. ⏳ Configure Google Maps API key in `.env`
3. ⏳ Test on Android device
4. ⏳ Test on iOS device (if applicable)
5. ⏳ Proceed with Phase 3 (Campus Map)

---

## Package Information

- **Package Name**: `com.campus_connect.geca`
- **Organization**: GECA (Government Engineering College)
- **App Name**: Campus Connect
- **Platforms**: Android, iOS, Web, Desktop

---

*Last Updated: After Phase 2 completion*
*Package Name Change: com.example.campus_connect_fl → com.campus_connect.geca*
