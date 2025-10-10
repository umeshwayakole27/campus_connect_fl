# Supabase Setup Guide for Campus Connect

## Prerequisites
- Supabase account (https://supabase.com)
- Flutter development environment set up

## Step 1: Create a Supabase Project

1. Go to https://supabase.com and sign in
2. Click "New Project"
3. Fill in project details:
   - Name: Campus Connect
   - Database Password: (choose a strong password)
   - Region: (select closest to your location)
4. Click "Create new project"
5. Wait for project to be provisioned

## Step 2: Get API Credentials

1. In your Supabase project dashboard, go to Settings > API
2. Copy the following values:
   - Project URL (e.g., https://xxxxx.supabase.co)
   - anon/public key

3. Update your `.env` file:
```
SUPABASE_URL=your_project_url_here
SUPABASE_ANON_KEY=your_anon_key_here
```

## Step 3: Create Database Schema

Go to SQL Editor in your Supabase dashboard and run the following SQL:

### 1. Enable UUID Extension
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

### 2. Create Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('student', 'faculty')),
  profile_pic TEXT,
  department TEXT,
  office TEXT,
  office_hours TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create index for faster queries
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
```

### 3. Create Campus Locations Table
```sql
CREATE TABLE campus_locations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  building_code TEXT,
  lat DOUBLE PRECISION NOT NULL,
  lng DOUBLE PRECISION NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_campus_locations_name ON campus_locations(name);
```

### 4. Create Events Table
```sql
CREATE TABLE events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  location TEXT,
  location_id UUID REFERENCES campus_locations(id),
  time TIMESTAMP WITH TIME ZONE NOT NULL,
  created_by UUID REFERENCES users(id) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_events_time ON events(time);
CREATE INDEX idx_events_created_by ON events(created_by);
```

### 5. Create Faculty Table
```sql
CREATE TABLE faculty (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) UNIQUE NOT NULL,
  name TEXT NOT NULL,
  department TEXT NOT NULL,
  office TEXT,
  office_hours TEXT,
  contact_email TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_faculty_department ON faculty(department);
CREATE INDEX idx_faculty_user_id ON faculty(user_id);
```

### 6. Create Notifications Table
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  event_id UUID REFERENCES events(id),
  type TEXT NOT NULL,
  message TEXT NOT NULL,
  sent_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  read BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(read);
```

## Step 4: Enable Row Level Security (RLS)

### Enable RLS on all tables
```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE faculty ENABLE ROW LEVEL SECURITY;
ALTER TABLE campus_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
```

### Users Table Policies
```sql
-- Users can view their own profile
CREATE POLICY "Users can view own profile"
ON users FOR SELECT
USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
ON users FOR UPDATE
USING (auth.uid() = id);

-- Allow insert during registration (will be handled by trigger)
CREATE POLICY "Allow user creation"
ON users FOR INSERT
WITH CHECK (true);
```

### Events Table Policies
```sql
-- Everyone can view events
CREATE POLICY "Everyone can view events"
ON events FOR SELECT
USING (true);

-- Only faculty can create events
CREATE POLICY "Faculty can create events"
ON events FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() 
    AND users.role = 'faculty'
  )
);

-- Faculty can update their own events
CREATE POLICY "Faculty can update own events"
ON events FOR UPDATE
USING (
  auth.uid() = created_by AND
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() 
    AND users.role = 'faculty'
  )
);

-- Faculty can delete their own events
CREATE POLICY "Faculty can delete own events"
ON events FOR DELETE
USING (
  auth.uid() = created_by AND
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() 
    AND users.role = 'faculty'
  )
);
```

### Faculty Table Policies
```sql
-- Everyone can view faculty
CREATE POLICY "Everyone can view faculty"
ON faculty FOR SELECT
USING (true);

-- Faculty can update their own info
CREATE POLICY "Faculty can update own info"
ON faculty FOR UPDATE
USING (auth.uid() = user_id);

-- Allow faculty creation
CREATE POLICY "Allow faculty creation"
ON faculty FOR INSERT
WITH CHECK (
  auth.uid() = user_id AND
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() 
    AND users.role = 'faculty'
  )
);
```

### Campus Locations Table Policies
```sql
-- Everyone can view locations
CREATE POLICY "Everyone can view campus locations"
ON campus_locations FOR SELECT
USING (true);

-- Only faculty can manage locations
CREATE POLICY "Faculty can manage locations"
ON campus_locations FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() 
    AND users.role = 'faculty'
  )
);
```

### Notifications Table Policies
```sql
-- Users can view their own notifications
CREATE POLICY "Users can view own notifications"
ON notifications FOR SELECT
USING (auth.uid() = user_id);

-- Only faculty can create notifications
CREATE POLICY "Faculty can create notifications"
ON notifications FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() 
    AND users.role = 'faculty'
  )
);

-- Users can update their own notifications (mark as read)
CREATE POLICY "Users can update own notifications"
ON notifications FOR UPDATE
USING (auth.uid() = user_id);
```

## Step 5: Create Automatic Updated_At Trigger

```sql
-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc', NOW());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to tables with updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_faculty_updated_at BEFORE UPDATE ON faculty
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

## Step 6: Insert Sample Data (Optional)

### Sample Campus Locations
```sql
INSERT INTO campus_locations (name, building_code, lat, lng, description) VALUES
('Main Library', 'LIB', 40.7128, -74.0060, 'Central campus library'),
('Science Building', 'SCI', 40.7138, -74.0050, 'Science and research labs'),
('Student Center', 'SC', 40.7118, -74.0070, 'Student activities and dining'),
('Engineering Hall', 'ENG', 40.7148, -74.0040, 'Engineering departments');
```

## Step 7: Configure Authentication

1. In Supabase Dashboard, go to Authentication > Providers
2. Enable Email provider
3. Configure email templates if needed
4. Set Site URL to your app's URL (for redirects)

## Step 8: Test Connection

Run your Flutter app and check the console for:
```
[INFO] Supabase initialized successfully
```

## Troubleshooting

### Connection Issues
- Verify SUPABASE_URL and SUPABASE_ANON_KEY in .env
- Check internet connection
- Ensure Supabase project is not paused

### RLS Issues
- Test policies with different user roles
- Use Supabase dashboard SQL editor to test queries
- Check auth.uid() returns correct user ID

### Migration Issues
- Run SQL scripts in order
- Check for error messages in SQL editor
- Ensure UUID extension is enabled

## Next Steps

After completing Supabase setup:
1. Update progress.md marking Phase 1 complete
2. Proceed to Phase 2: Authentication & User Management
3. Test with both student and faculty accounts

## Security Best Practices

- Never commit .env file to version control
- Use RLS policies for all tables
- Regularly rotate API keys
- Monitor usage in Supabase dashboard
- Enable database backups
- Use prepared statements for queries
- Validate all user inputs

## Useful Supabase Commands

### Check RLS Policies
```sql
SELECT * FROM pg_policies WHERE tablename = 'events';
```

### View Current User
```sql
SELECT auth.uid(), auth.jwt();
```

### Test RLS as User
```sql
SET request.jwt.claim.sub = 'user-uuid-here';
SELECT * FROM events;
```
