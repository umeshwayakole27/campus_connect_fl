# Phase 5 Setup: Faculty Directory Module

## Overview
Phase 5 implements a comprehensive Faculty Directory system that allows all users to browse, search, and view detailed faculty information including office locations, contact details, and research interests.

---

## 🎯 Objectives

### Core Features
1. **Faculty List View** - Browse all faculty members
2. **Faculty Detail View** - View detailed faculty profile
3. **Search & Filter** - Find faculty by name or department
4. **Department Grouping** - Organize faculty by department
5. **Office Location Integration** - Link to campus map
6. **Contact Information** - Email, phone, office hours
7. **Profile Editing** - Faculty can edit own profile

### User Roles
- **Students**: Can view all faculty information
- **Faculty**: Can view all faculty + edit own profile

---

## 📋 Prerequisites

### Completed Phases
- ✅ Phase 1: Project Setup
- ✅ Phase 2: Authentication
- ✅ Phase 3: Campus Map
- ✅ Phase 4: Event Management

### Code Implementation
✅ All Phase 5 code has been implemented:
- Faculty repository with caching
- Faculty provider for state management
- Faculty list screen with search and filters
- Faculty detail screen with contact actions
- Edit faculty screen with form validation

---

## 🗄️ Database Setup

### Step 1: Update Faculty Table Structure

The faculty table from SUPABASE_SETUP.md needs to be updated to match Phase 5 requirements. Run this SQL in your Supabase SQL Editor:

```sql
-- Safely update faculty table structure
-- This script adds missing columns without affecting existing data

DO $$ 
BEGIN
  -- Add designation column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'faculty' AND column_name = 'designation'
  ) THEN
    ALTER TABLE faculty ADD COLUMN designation TEXT;
  END IF;

  -- Rename 'office' to 'office_location' if needed
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'faculty' AND column_name = 'office'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'faculty' AND column_name = 'office_location'
  ) THEN
    ALTER TABLE faculty RENAME COLUMN office TO office_location;
  END IF;

  -- Add office_location column if it doesn't exist (and 'office' doesn't exist)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'faculty' AND column_name = 'office_location'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'faculty' AND column_name = 'office'
  ) THEN
    ALTER TABLE faculty ADD COLUMN office_location TEXT;
  END IF;

  -- Add phone column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'faculty' AND column_name = 'phone'
  ) THEN
    ALTER TABLE faculty ADD COLUMN phone TEXT;
  END IF;

  -- Add research_interests column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'faculty' AND column_name = 'research_interests'
  ) THEN
    ALTER TABLE faculty ADD COLUMN research_interests TEXT[];
  END IF;

  -- Remove old columns that are no longer needed
  -- 'name' column (data now comes from users table join)
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'faculty' AND column_name = 'name'
  ) THEN
    ALTER TABLE faculty DROP COLUMN name;
  END IF;

  -- 'contact_email' column (data now comes from users table join)
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'faculty' AND column_name = 'contact_email'
  ) THEN
    ALTER TABLE faculty DROP COLUMN contact_email;
  END IF;
END $$;

-- Ensure indexes exist
CREATE INDEX IF NOT EXISTS idx_faculty_department ON faculty(department);
CREATE INDEX IF NOT EXISTS idx_faculty_user_id ON faculty(user_id);
```

### Step 2: Enable Row Level Security

```sql
-- Enable RLS on faculty table
ALTER TABLE faculty ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist to avoid conflicts
DROP POLICY IF EXISTS "Everyone can view faculty" ON faculty;
DROP POLICY IF EXISTS "Faculty can update own profile" ON faculty;
DROP POLICY IF EXISTS "System can insert faculty" ON faculty;
DROP POLICY IF EXISTS "Anyone can view faculty" ON faculty;
DROP POLICY IF EXISTS "Faculty can update own record" ON faculty;

-- Policy 1: Everyone can view faculty
CREATE POLICY "Everyone can view faculty"
ON faculty FOR SELECT
USING (true);

-- Policy 2: Faculty can update own profile
CREATE POLICY "Faculty can update own profile"
ON faculty FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy 3: System can insert faculty profiles (via triggers)
CREATE POLICY "System can insert faculty"
ON faculty FOR INSERT
WITH CHECK (true);
```

### Step 3: Create Auto-Insert Trigger

This trigger automatically creates a faculty record when a user registers with role='faculty':

```sql
-- Drop existing function and trigger if they exist
DROP TRIGGER IF EXISTS on_user_created_create_faculty ON users;
DROP FUNCTION IF EXISTS create_faculty_profile();

-- Create function to auto-create faculty profile
CREATE OR REPLACE FUNCTION create_faculty_profile()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.role = 'faculty' THEN
    -- Insert faculty record with department from users table
    INSERT INTO faculty (user_id, department, designation)
    VALUES (
      NEW.id,
      COALESCE(NEW.department, 'General'),
      'Faculty Member'
    )
    ON CONFLICT (user_id) DO NOTHING;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger
CREATE TRIGGER on_user_created_create_faculty
  AFTER INSERT ON users
  FOR EACH ROW
  EXECUTE FUNCTION create_faculty_profile();
```

### Step 4: Add Sample Faculty Data (Optional)

```sql
-- First, ensure you have some faculty users in the users table
-- This is just sample data - adjust as needed

-- Insert sample faculty users if they don't exist
INSERT INTO users (id, email, name, role, department) VALUES
('11111111-1111-1111-1111-111111111111', 'dr.sharma@geca.ac.in', 'Dr. Amit Sharma', 'faculty', 'Computer Science'),
('22222222-2222-2222-2222-222222222222', 'dr.patel@geca.ac.in', 'Dr. Priya Patel', 'faculty', 'Electronics & Telecommunication'),
('33333333-3333-3333-3333-333333333333', 'prof.kumar@geca.ac.in', 'Prof. Rajesh Kumar', 'faculty', 'Mechanical Engineering')
ON CONFLICT (id) DO NOTHING;

-- Update or insert faculty records with full details
INSERT INTO faculty (user_id, department, designation, office_location, office_hours, phone, research_interests)
VALUES
  (
    '11111111-1111-1111-1111-111111111111',
    'Computer Science',
    'Professor & HOD',
    'CSE Block, Room 301',
    'Mon-Fri: 10:00 AM - 12:00 PM',
    '+91-9876543210',
    ARRAY['Machine Learning', 'Artificial Intelligence', 'Data Science']
  ),
  (
    '22222222-2222-2222-2222-222222222222',
    'Electronics & Telecommunication',
    'Associate Professor',
    'ETC Block, Room 205',
    'Tue-Thu: 2:00 PM - 4:00 PM',
    '+91-9876543211',
    ARRAY['VLSI Design', 'Embedded Systems', 'IoT']
  ),
  (
    '33333333-3333-3333-3333-333333333333',
    'Mechanical Engineering',
    'Assistant Professor',
    'Mech Block, Room 101',
    'Mon-Wed-Fri: 11:00 AM - 1:00 PM',
    '+91-9876543212',
    ARRAY['Robotics', 'Manufacturing', 'CAD/CAM']
  )
ON CONFLICT (user_id) 
DO UPDATE SET
  designation = EXCLUDED.designation,
  office_location = EXCLUDED.office_location,
  office_hours = EXCLUDED.office_hours,
  phone = EXCLUDED.phone,
  research_interests = EXCLUDED.research_interests,
  updated_at = NOW();
```

### Step 5: Verify Setup

Run these queries to verify everything is set up correctly:

```sql
-- Check faculty table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'faculty'
ORDER BY ordinal_position;

-- Expected columns:
-- id (uuid)
-- user_id (uuid)
-- department (text)
-- designation (text)
-- office_location (text)
-- office_hours (text)
-- phone (text)
-- research_interests (text[])
-- created_at (timestamp with time zone)
-- updated_at (timestamp with time zone)

-- Check RLS policies
SELECT schemaname, tablename, policyname, roles, cmd, qual
FROM pg_policies
WHERE tablename = 'faculty';

-- Check if trigger exists
SELECT trigger_name, event_manipulation, event_object_table
FROM information_schema.triggers
WHERE trigger_name = 'on_user_created_create_faculty';

-- Check faculty count
SELECT COUNT(*) as faculty_count FROM faculty;

-- View faculty with user data
SELECT 
  f.id,
  f.department,
  f.designation,
  f.office_location,
  u.name as faculty_name,
  u.email as faculty_email
FROM faculty f
JOIN users u ON f.user_id = u.id
LIMIT 5;
```

---

## 🧪 Testing the Faculty Module

### Test as Student
1. Login with student account
2. Navigate to Faculty tab
3. Verify you can:
   - See faculty list
   - Search faculty
   - Filter by department
   - View faculty details
   - See contact information
   - **Cannot** see edit button

### Test as Faculty
1. Login with faculty account
2. Navigate to Faculty tab
3. Find your own profile
4. Verify you can:
   - View your profile
   - Click edit button
   - Update all fields
   - Save changes
   - **Cannot** edit other faculty profiles

### Test Contact Actions (Device Only)
1. Tap email - should open email client
2. Tap phone - should open dialer
3. Verify correct information is pre-filled

---

## 🔧 Troubleshooting

### Issue: "column users_1.avatar_url does not exist"
**Solution**: This is expected. The users table doesn't have avatar_url column. The code has been updated to exclude it.

### Issue: Faculty table structure doesn't match
**Solution**: Run the Step 1 SQL script above. It safely updates the table structure.

### Issue: No faculty showing in list
**Solution**: 
1. Verify faculty records exist: `SELECT COUNT(*) FROM faculty;`
2. Check RLS policies are enabled
3. Ensure users table has corresponding records

### Issue: Cannot edit own profile
**Solution**: 
1. Verify you're logged in as faculty
2. Check RLS policy: `SELECT * FROM pg_policies WHERE tablename = 'faculty';`
3. Verify auth.uid() matches your user_id

### Issue: Trigger not creating faculty records
**Solution**:
1. Check trigger exists: `SELECT * FROM information_schema.triggers WHERE trigger_name = 'on_user_created_create_faculty';`
2. Verify function exists: `\df create_faculty_profile`
3. Test manually by inserting a faculty user

### Issue: "already exists" errors when running SQL
**Solution**: The SQL scripts use `IF NOT EXISTS` and `DROP IF EXISTS` to prevent conflicts. They are safe to run multiple times.

---

## 📊 Database Schema Reference

### Final Faculty Table Structure
```sql
faculty (
  id UUID PRIMARY KEY,
  user_id UUID UNIQUE REFERENCES users(id),
  department TEXT NOT NULL,
  designation TEXT,
  office_location TEXT,
  office_hours TEXT,
  phone TEXT,
  research_interests TEXT[],
  created_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE
)
```

### Relationships
- `faculty.user_id` → `users.id` (one-to-one)
- Faculty data joins with users table for name, email

### Indexes
- `idx_faculty_department` on `department`
- `idx_faculty_user_id` on `user_id`

---

## 🔒 Security

### RLS Policies
1. **SELECT**: Everyone can view all faculty (public information)
2. **UPDATE**: Faculty can only update their own profile
3. **INSERT**: System only (via trigger on user registration)
4. **DELETE**: Not allowed (data integrity)

### Data Privacy
- Email and phone are visible to all (considered public contact info)
- Office hours are visible to all (for student meetings)
- No sensitive personal data stored in faculty table

---

## ✅ Completion Checklist

Before moving to Phase 6, verify:
- [ ] Faculty table structure updated
- [ ] RLS policies created and tested
- [ ] Trigger created for auto-inserting faculty records
- [ ] Sample faculty data added (at least 2-3 records)
- [ ] Faculty list displays correctly in app
- [ ] Search functionality works
- [ ] Department filter works
- [ ] Faculty details show all information
- [ ] Edit profile works (faculty only)
- [ ] Contact actions work (email, phone)
- [ ] No console errors

---

## 📚 Additional Notes

### Differences from SUPABASE_SETUP.md

The original `SUPABASE_SETUP.md` created a faculty table with these columns:
- `name` - **REMOVED** (now fetched from users table join)
- `office` - **RENAMED** to `office_location`
- `contact_email` - **REMOVED** (now fetched from users table join)

Phase 5 added these new columns:
- `designation` - Job title (Professor, Assistant Professor, etc.)
- `phone` - Contact phone number
- `research_interests` - Array of research areas

This migration is handled safely by the Step 1 SQL script.

### Why These Changes?

1. **Removed redundant data**: Name and email are already in users table
2. **Better data normalization**: Single source of truth for user info
3. **Richer faculty profiles**: Added designation and research interests
4. **Clearer naming**: office → office_location
5. **Flexible research interests**: Using array type for multiple interests

---

## 🚀 Next Steps

After Phase 5 is complete and tested:
- **Phase 6**: Search & Notifications Module
  - Global search across all data
  - Push notifications for events
  - Notification preferences
  - Real-time updates

---

**Phase 5 Status**: ✅ **COMPLETE**  
**Database Setup**: ⏳ **Follow steps above**  
**Testing**: ⏳ **Test all features**

---

*Last Updated: 2025-01-11*
*For code implementation details, see PHASE5_SUMMARY.md*
*For overall progress, see progress.md*
