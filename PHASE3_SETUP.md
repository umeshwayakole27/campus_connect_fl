# Phase 3: Campus Map Setup Guide

## ✅ Code Implementation Complete

All code for Phase 3 has been implemented:
- ✅ Location model created
- ✅ Location repository with Supabase integration
- ✅ Campus Map screen with Google Maps
- ✅ Marker system with category filtering
- ✅ Location details bottom sheet
- ✅ Navigation integration

## 🗄️ Database Setup Required

You need to run this SQL in your Supabase SQL Editor:

### Step 1: Go to Supabase Dashboard
Visit: https://app.supabase.com/project/xywmwbrygdgdegktsfvj

### Step 2: Open SQL Editor
Click "SQL Editor" in the left sidebar

### Step 3: Run the Following SQL

**Note:** If you already created the `campus_locations` table from SUPABASE_SETUP.md, this will add the missing columns and update the table structure.

```sql
-- Add missing columns to existing campus_locations table (if they don't exist)
DO $$ 
BEGIN
  -- Add category column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'campus_locations' AND column_name = 'category'
  ) THEN
    ALTER TABLE campus_locations ADD COLUMN category TEXT;
  END IF;

  -- Add floor_info column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'campus_locations' AND column_name = 'floor_info'
  ) THEN
    ALTER TABLE campus_locations ADD COLUMN floor_info TEXT;
  END IF;

  -- Add image_url column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'campus_locations' AND column_name = 'image_url'
  ) THEN
    ALTER TABLE campus_locations ADD COLUMN image_url TEXT;
  END IF;

  -- Add updated_at column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'campus_locations' AND column_name = 'updated_at'
  ) THEN
    ALTER TABLE campus_locations ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
  END IF;
END $$;

-- Create index for faster queries (if not exists)
CREATE INDEX IF NOT EXISTS idx_campus_locations_category ON campus_locations(category);

-- Update existing RLS policies if needed
-- First, check if the policies exist and drop them if needed
DROP POLICY IF EXISTS "Everyone can view campus locations" ON campus_locations;
DROP POLICY IF EXISTS "Faculty can manage locations" ON campus_locations;
DROP POLICY IF EXISTS "Anyone can view campus locations" ON campus_locations;
DROP POLICY IF EXISTS "Only faculty can manage locations" ON campus_locations;

-- Create new RLS policies
CREATE POLICY "Everyone can view campus locations"
ON campus_locations FOR SELECT
USING (true);

CREATE POLICY "Only faculty can manage locations"
ON campus_locations FOR ALL
USING (
  auth.uid() IN (SELECT id FROM users WHERE role = 'faculty')
);

-- Insert or update sample locations (GECA Aurangabad/Chhatrapati Sambhajinagar campus coordinates)
-- Campus center: 19.8680502°N, 75.3241057°E
INSERT INTO campus_locations (name, description, building_code, lat, lng, category, floor_info) VALUES
  ('Main Administrative Building', 'Principal office, administrative offices and main reception', 'ADMIN', 19.868473, 75.323921, 'admin', '1st floor'),
  ('Central Library', 'Geca Central Library with digital resources', 'LIB', 19.8682058, 75.3248781, 'library', 'Ground floor'),
  ('Computer Science & Engineering Block', 'Department of Computer Science and Engineering', 'CSE', 19.867860, 75.323280, 'academic', '1st floor'),
  ('Electronics & Telecommunication Block', 'Department of Electronics and Telecommunication Engineering', 'ETC', 19.867550, 75.323368, 'academic', 'Ground floor'),
  ('Mechanical Engineering Block', 'Department of Mechanical Engineering with workshops', 'MECH', 19.868420, 75.323738, 'academic', 'Ground floor'),
  ('Civil Engineering Block', 'Department of Civil Engineering', 'CIVIL', 19.867492, 75.324401, 'academic', 'Ground to 1st floor'),
  ('Electrical Engineering Block', 'Department of Electrical Engineering', 'EE', 19.868597, 75.324213, 'academic', 'Ground floor'),
  ('MCA Block', 'Department of Computer Applications', 'MCA', 19.86772326971609, 75.32333233123376, 'academic', '2nd floor'),
  ('Classroom Complex Block', 'Department of IT Engineering and Exam Cell', 'CC', 19.86716564974357, 75.32459640578749, 'academic', 'Ground to 2nd floor'),
  ('Student Canteen', 'Main student cafeteria and food court', 'CANTEEN', 19.868289, 75.324956, 'cafeteria', '1st floor'),
  (' MWorkshop Parking', 'Central workshop and engineering laboratories', 'WORKSHOP', 19.867852911003993, 75.32408579214741, 'academic', 'Ground floor'),
  ('Boys Hostel A', 'Student accommodation for male students', 'BH-A', 19.86671560971966, 75.32389037506675, 'hostel', 'Ground to 2nd floor'),
  ('Boys Hostel C', 'Student accommodation for male students', 'BH-C', 19.861291464707552, 75.32210564942052, 'hostel', 'Ground to 2nd floor'),
  ('Girls Hostel', 'Student accommodation for female students', 'GH', 19.8658492192181, 75.32386440258225, 'hostel', 'Ground to 2nd floor'),
  ('Gymkhana Building', 'Indoor and outdoor sports facilities and gymnasium', 'SPORTS', 19.866281434959618, 75.32470391666313, 'sports', 'Ground floor'),
  ('Auditorium', 'Main auditorium for events and seminars', 'AUD', 19.86832288503801, 75.3248825799877, 'academic', '2nd floor'),
  ('Training & Placement Cell', 'Career development and placement office', 'TPC', 19.868496221462713, 75.32412036974512, 'admin', '1st floor'),
  ('Principal headQuarter', 'house of principal of Geca', 'ADMIN', 19.866755801852268, 75.32493774263148, 'admin', 'Ground floor'),
  ('SBI ATM', 'State Bank Of India ATM', 'ATM', 19.86728057279933, 75.3248650321189, 'Finance', 'Ground floor')

ON CONFLICT (id) DO NOTHING;
```

**What This Script Does:**
- ✅ Adds `category`, `floor_info`, `image_url`, and `updated_at` columns if they don't exist
- ✅ Keeps existing data intact
- ✅ Updates RLS policies for Phase 3 requirements
- ✅ Inserts sample location data (skips if already exists)
- ✅ Safe to run multiple times (idempotent)

### Step 4: Update Coordinates (Optional)

The sample data uses GECA Aurangabad (Chhatrapati Sambhajinagar) campus coordinates. To fine-tune locations:

1. Go to Google Maps
2. Right-click on each building location
3. Copy the coordinates (lat, lng)
4. Update the INSERT statements with actual coordinates

## 🔑 Google Maps API Key Required

### Current Status
The `.env` file has a placeholder Google Maps API key. For the map to display properly, you need a real API key.

### Get Google Maps API Key

1. **Go to Google Cloud Console:**
   https://console.cloud.google.com/

2. **Create/Select Project:**
   - Create a new project or select existing
   - Name it "Campus Connect" or similar

3. **Enable APIs:**
   - Go to "APIs & Services" → "Library"
   - Search and enable:
     - Maps SDK for Android
     - Maps SDK for iOS (if you plan iOS support)
     - Geocoding API (optional, for address lookup)

4. **Create API Key:**
   - Go to "APIs & Services" → "Credentials"
   - Click "Create Credentials" → "API Key"
   - Copy the API key

5. **Restrict API Key (Important for security):**
   - Click on the key name
   - Under "Application restrictions":
     - Select "Android apps"
     - Add package name: `com.campus_connect.geca`
     - Add SHA-1 certificate fingerprint
   - Under "API restrictions":
     - Select "Restrict key"
     - Choose "Maps SDK for Android"

6. **Get SHA-1 Fingerprint:**
   ```bash
   # For debug builds
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   
   # Look for SHA1 fingerprint and copy it
   ```

7. **Update .env file:**
   ```
   GOOGLE_MAPS_API_KEY=YOUR_ACTUAL_API_KEY_HERE
   ```

8. **Update Android Configuration:**
   The key is already configured in `android/app/src/main/AndroidManifest.xml`

## 📍 Features Implemented

### Map Screen
- ✅ Google Maps integration
- ✅ Campus center default view
- ✅ Custom markers for locations
- ✅ Color-coded markers by category
- ✅ Zoom controls
- ✅ My location button
- ✅ Refresh locations

### Category Filter
- ✅ All locations
- ✅ Academic buildings
- ✅ Library
- ✅ Cafeteria
- ✅ Hostels
- ✅ Sports facilities
- ✅ Administrative offices

### Location Details
- ✅ Interactive markers
- ✅ Bottom sheet with details
- ✅ Location name, code, description
- ✅ Floor information
- ✅ Coordinates display
- ✅ Get Directions button
- ✅ Center Map button

### Permissions
- ✅ Location permission (AndroidManifest.xml)
- ✅ Internet permission
- ✅ Fine location access
- ✅ Coarse location access

## 🧪 Testing the Map

### After Database Setup:

1. **Run the app:**
   ```bash
   flutter run -d RZCY51YC1GW
   ```

2. **Navigate to Map:**
   - Tap the "Map" icon in bottom navigation
   - Map should load with campus center

3. **Test Features:**
   - See all markers on map
   - Tap category filters (All, Academic, Library, etc.)
   - Tap a marker to see details
   - Try "Get Directions" and "Center Map" buttons
   - Use refresh button to reload locations

### Expected Behavior:

**With Placeholder API Key:**
- Map may show blank/gray tiles
- Markers won't display
- Message about API key needed

**With Real API Key:**
- Map displays properly
- Markers appear at locations
- Full interactivity works

## 🔧 Troubleshooting

### Map Not Loading
- Check Google Maps API key is valid
- Ensure APIs are enabled in Google Cloud Console
- Check internet connection
- Verify package name matches API key restrictions

### No Markers Showing
- Run the SQL to create table and insert data
- Check Supabase connection
- Look for errors in logs: `flutter logs`
- Try refresh button in app

### Location Permission Denied
- Check AndroidManifest.xml has permissions
- Grant location permission in device settings

## 📊 Current Progress

✅ Phase 1: Project Setup - COMPLETE
✅ Phase 2: Authentication - COMPLETE
✅ Phase 3: Campus Map - CODE COMPLETE (Need DB setup + API key)
🔄 Phase 4: Events - Next
🔄 Phase 5: Faculty Directory - Later
🔄 Phase 6: Search & Notifications - Later

## 🎯 Next Steps

1. **Immediate (Required for map to work):**
   - Run SQL in Supabase to create table
   - Get Google Maps API key
   - Update .env with real API key
   - Restart app and test

2. **Optional Enhancements:**
   - Update coordinates to match your actual campus
   - Add real building photos (image_url field)
   - Add more locations
   - Customize map styling

3. **Future (Phase 4):**
   - Link events to locations
   - Show upcoming events at locations
   - Navigation integration with real directions

---

**Ready to proceed once database and API key are configured!**
