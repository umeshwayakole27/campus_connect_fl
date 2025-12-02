-- Campus Connect Database Schema for Supabase
-- Migration: Create complete database schema

-- Create user_profiles table
CREATE TABLE IF NOT EXISTS user_profiles (
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL DEFAULT '',
    phone_number VARCHAR(20),
    avatar_url TEXT,
    department VARCHAR(100),
    student_id VARCHAR(50),
    role VARCHAR(20) NOT NULL DEFAULT 'student' CHECK (role IN ('student', 'faculty', 'staff', 'admin')),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
)
-- Create locations table
CREATE TABLE IF NOT EXISTS locations (
    location_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    location_type VARCHAR(50) NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    address TEXT,
    building_name VARCHAR(255),
    floor_number INTEGER,
    room_number VARCHAR(50),
    capacity INTEGER,
    amenities TEXT[],
    accessibility_info TEXT,
    operating_hours JSONB,
    contact_info JSONB,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
)
-- Create faculty table
CREATE TABLE IF NOT EXISTS faculty (
    faculty_id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    employee_id VARCHAR(50) UNIQUE,
    department VARCHAR(100) NOT NULL,
    designation VARCHAR(100) NOT NULL,
    specializations TEXT[],
    qualifications TEXT[],
    bio TEXT,
    office_location VARCHAR(255),
    office_hours JSONB,
    research_interests TEXT[],
    publications TEXT[],
    awards TEXT[],
    is_available BOOLEAN DEFAULT true,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
)
-- Create events table
CREATE TABLE IF NOT EXISTS events (
    event_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    event_date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    venue_name VARCHAR(255),
    venue_location_id INTEGER REFERENCES locations(location_id),
    organizer_name VARCHAR(255),
    organizer_contact JSONB,
    category VARCHAR(50) NOT NULL,
    event_type VARCHAR(50) DEFAULT 'public',
    registration_required BOOLEAN DEFAULT false,
    max_attendees INTEGER,
    current_attendees INTEGER DEFAULT 0,
    registration_deadline TIMESTAMP WITH TIME ZONE,
    event_image_url TEXT,
    tags TEXT[],
    is_featured BOOLEAN DEFAULT false,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
)
-- Create event_registrations table
CREATE TABLE IF NOT EXISTS event_registrations (
    registration_id SERIAL PRIMARY KEY,
    event_id INTEGER REFERENCES events(event_id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    registration_status VARCHAR(20) DEFAULT 'registered' CHECK (registration_status IN ('registered', 'cancelled', 'attended')),
    registration_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    cancellation_date TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    UNIQUE(event_id, user_id)
)
-- Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
    notification_id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    notification_type VARCHAR(50) NOT NULL CHECK (notification_type IN ('event', 'announcement', 'academic', 'emergency', 'social', 'system', 'reminder', 'update')),
    priority VARCHAR(20) DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    is_read BOOLEAN DEFAULT false,
    is_archived BOOLEAN DEFAULT false,
    scheduled_at TIMESTAMP WITH TIME ZONE,
    data JSONB,
    image_url TEXT,
    action_url TEXT,
    action_text VARCHAR(100),
    related_id INTEGER,
    related_type VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    read_at TIMESTAMP WITH TIME ZONE,
    archived_at TIMESTAMP WITH TIME ZONE
)
-- Create user_preferences table
CREATE TABLE IF NOT EXISTS user_preferences (
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    notification_settings JSONB DEFAULT '{}',
    theme_preference VARCHAR(20) DEFAULT 'system',
    language_preference VARCHAR(10) DEFAULT 'en',
    privacy_settings JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
)
-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_profiles_email ON user_profiles(email)
CREATE INDEX IF NOT EXISTS idx_user_profiles_role ON user_profiles(role)
CREATE INDEX IF NOT EXISTS idx_locations_type ON locations(location_type)
CREATE INDEX IF NOT EXISTS idx_locations_active ON locations(is_active)
CREATE INDEX IF NOT EXISTS idx_faculty_department ON faculty(department)
CREATE INDEX IF NOT EXISTS idx_faculty_active ON faculty(is_active)
CREATE INDEX IF NOT EXISTS idx_events_date ON events(event_date)
CREATE INDEX IF NOT EXISTS idx_events_category ON events(category)
CREATE INDEX IF NOT EXISTS idx_events_active ON events(is_active)
CREATE INDEX IF NOT EXISTS idx_event_registrations_user ON event_registrations(user_id)
CREATE INDEX IF NOT EXISTS idx_event_registrations_event ON event_registrations(event_id)
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id)
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(is_read)
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(notification_type)
-- Enable Row Level Security (RLS)
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY
ALTER TABLE faculty ENABLE ROW LEVEL SECURITY
ALTER TABLE events ENABLE ROW LEVEL SECURITY
ALTER TABLE event_registrations ENABLE ROW LEVEL SECURITY
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY
-- RLS Policies for user_profiles
CREATE POLICY "Users can view own profile" ON user_profiles
    FOR SELECT USING (auth.uid() = user_id)
CREATE POLICY "Users can update own profile" ON user_profiles
    FOR UPDATE USING (auth.uid() = user_id)
CREATE POLICY "Users can insert own profile" ON user_profiles
    FOR INSERT WITH CHECK (auth.uid() = user_id)
-- RLS Policies for faculty (public read, own update)
CREATE POLICY "Faculty profiles are publicly readable" ON faculty
    FOR SELECT USING (is_active = true)
CREATE POLICY "Faculty can update own profile" ON faculty
    FOR UPDATE USING (auth.uid() = user_id)
CREATE POLICY "Faculty can insert own profile" ON faculty
    FOR INSERT WITH CHECK (auth.uid() = user_id)
-- RLS Policies for events (public read, authenticated create)
CREATE POLICY "Events are publicly readable" ON events
    FOR SELECT USING (is_active = true)
CREATE POLICY "Authenticated users can create events" ON events
    FOR INSERT WITH CHECK (auth.role() = 'authenticated')
CREATE POLICY "Event creators can update own events" ON events
    FOR UPDATE USING (auth.uid() = created_by)
-- RLS Policies for event_registrations
CREATE POLICY "Users can view own registrations" ON event_registrations
    FOR SELECT USING (auth.uid() = user_id)
CREATE POLICY "Users can create own registrations" ON event_registrations
    FOR INSERT WITH CHECK (auth.uid() = user_id)
CREATE POLICY "Users can update own registrations" ON event_registrations
    FOR UPDATE USING (auth.uid() = user_id)
-- RLS Policies for notifications
CREATE POLICY "Users can view own notifications" ON notifications
    FOR SELECT USING (auth.uid() = user_id)
CREATE POLICY "Users can update own notifications" ON notifications
    FOR UPDATE USING (auth.uid() = user_id)
-- RLS Policies for user_preferences
CREATE POLICY "Users can manage own preferences" ON user_preferences
    FOR ALL USING (auth.uid() = user_id)
-- Create policy to allow all authenticated users to view all users
CREATE POLICY "Allow authenticated users to view all users" ON users
     FOR SELECT TO authenticated
     USING (true);

-- Create functions for automatic timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql'
-- Create triggers for updated_at
CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column()
CREATE TRIGGER update_locations_updated_at BEFORE UPDATE ON locations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column()
CREATE TRIGGER update_faculty_updated_at BEFORE UPDATE ON faculty
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column()
CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column()
CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON user_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column()
-- Insert sample data
-- Sample locations
INSERT INTO locations (name, description, location_type, latitude, longitude, address, building_name) VALUES
('Main Library', 'Central campus library with extensive collection', 'Library', 40.7128, -74.0060, '123 Campus Drive', 'Academic Building A'),
('Computer Science Lab', 'Advanced computing laboratory', 'Laboratory', 40.7130, -74.0058, '125 Campus Drive', 'Science Building'),
('Student Center', 'Hub for student activities and dining', 'Student Center', 40.7125, -74.0062, '121 Campus Drive', 'Student Life Building')
-- Sample events
INSERT INTO events (title, description, event_date, start_time, end_time, venue_name, category, organizer_name) VALUES
('Welcome Week Orientation', 'New student orientation program', CURRENT_DATE + INTERVAL '7 days', '09:00:00', '17:00:00', 'Main Auditorium', 'Academic', 'Student Affairs'),
('Tech Talk: AI in Education', 'Guest speaker on artificial intelligence applications', CURRENT_DATE + INTERVAL '14 days', '14:00:00', '16:00:00', 'Computer Science Lab', 'Academic', 'CS Department')
-- Add table comments
COMMENT ON TABLE user_profiles IS 'Extended user profile information'
COMMENT ON TABLE locations IS 'Campus locations and facilities'
COMMENT ON TABLE faculty IS 'Faculty member profiles and information'
COMMENT ON TABLE events IS 'Campus events and activities'
COMMENT ON TABLE event_registrations IS 'User registrations for events'
COMMENT ON TABLE notifications IS 'User notifications and alerts'
COMMENT ON TABLE user_preferences IS 'User application preferences and settings'
