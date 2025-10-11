# Phase 4: Event Management Module - Setup Guide

## Overview
This phase implements event creation, viewing, editing, and deletion with role-based access control. Faculty members can create and manage events, while students can only view them.

---

## Database Setup

### Verify Events Table Exists
The `events` table should already exist from Phase 1. Verify it has the correct structure:

```sql
-- Check events table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'events';
```

Expected columns:
- `id` (uuid, primary key)
- `title` (text, not null)
- `description` (text)
- `location` (text)
- `location_id` (uuid, foreign key to campus_locations)
- `time` (timestamp with time zone, not null)
- `created_by` (uuid, foreign key to users, not null)
- `created_at` (timestamp with time zone)
- `updated_at` (timestamp with time zone)

### Row Level Security (RLS) Policies

Enable RLS on the events table and create policies:

```sql
-- Enable RLS
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Everyone can view events" ON events;
DROP POLICY IF EXISTS "Faculty can create events" ON events;
DROP POLICY IF EXISTS "Faculty can update own events" ON events;
DROP POLICY IF EXISTS "Faculty can delete own events" ON events;

-- Policy 1: Everyone can view events
CREATE POLICY "Everyone can view events"
ON events FOR SELECT
USING (true);

-- Policy 2: Only faculty can create events
CREATE POLICY "Faculty can create events"
ON events FOR INSERT
WITH CHECK (
  auth.uid() IN (SELECT id FROM users WHERE role = 'faculty')
);

-- Policy 3: Only faculty who created the event can update it
CREATE POLICY "Faculty can update own events"
ON events FOR UPDATE
USING (
  auth.uid() = created_by AND
  auth.uid() IN (SELECT id FROM users WHERE role = 'faculty')
);

-- Policy 4: Only faculty who created the event can delete it
CREATE POLICY "Faculty can delete own events"
ON events FOR DELETE
USING (
  auth.uid() = created_by AND
  auth.uid() IN (SELECT id FROM users WHERE role = 'faculty')
);
```

### Add Sample Events (Optional)

```sql
-- Insert sample events (replace user_id and location_id with actual values)
INSERT INTO events (title, description, location, location_id, time, created_by)
VALUES 
  (
    'Tech Fest 2024',
    'Annual technical festival featuring competitions, workshops, and tech exhibitions.',
    'Main Auditorium',
    (SELECT id FROM campus_locations WHERE name LIKE '%Auditorium%' LIMIT 1),
    NOW() + INTERVAL '7 days',
    (SELECT id FROM users WHERE role = 'faculty' LIMIT 1)
  ),
  (
    'Career Guidance Workshop',
    'Interactive session on career planning and industry trends.',
    'Seminar Hall',
    (SELECT id FROM campus_locations WHERE name LIKE '%Seminar%' LIMIT 1),
    NOW() + INTERVAL '3 days',
    (SELECT id FROM users WHERE role = 'faculty' LIMIT 1)
  ),
  (
    'Sports Day',
    'Annual sports competition with multiple events.',
    'Sports Complex',
    (SELECT id FROM campus_locations WHERE name LIKE '%Sports%' LIMIT 1),
    NOW() + INTERVAL '14 days',
    (SELECT id FROM users WHERE role = 'faculty' LIMIT 1)
  );
```

---

## Files Created

### Data Layer
- **`lib/features/events/data/event_repository.dart`**
  - Handles all event CRUD operations
  - Implements caching (2 minutes)
  - Fetches events with related user and location data

### State Management
- **`lib/features/events/presentation/event_provider.dart`**
  - Manages event state
  - Provides filtering (all, upcoming, today, past)
  - Handles loading and error states

### Presentation Layer
- **`lib/features/events/presentation/events_screen.dart`**
  - Lists all events with filters
  - Shows event cards with date badges
  - Faculty can create events via FAB
  - Pull-to-refresh functionality

- **`lib/features/events/presentation/event_detail_screen.dart`**
  - Shows complete event details
  - Faculty can edit/delete own events
  - Links to campus location on map (coming soon)
  - Shows organizer information

- **`lib/features/events/presentation/create_edit_event_screen.dart`**
  - Create/edit event form
  - Date and time pickers
  - Campus location dropdown
  - Custom location option
  - Form validation

---

## Features Implemented

### For All Users (Students & Faculty)
- ✅ View all events
- ✅ Filter events (All, Upcoming, Today, Past)
- ✅ View event details
- ✅ See event location and time
- ✅ Pull to refresh events list
- ✅ Visual indicators for past/today/upcoming events

### For Faculty Only
- ✅ Create new events
- ✅ Edit own events
- ✅ Delete own events
- ✅ Link events to campus locations
- ✅ Set custom locations
- ✅ "My Event" badge on created events

### Security
- ✅ RLS enforces faculty-only create/edit/delete
- ✅ Students cannot access create/edit screens
- ✅ UI hides faculty features for students
- ✅ Backend validates all operations

---

## UI Features

### Event Card
- Date badge with month and day
- Event title and description
- Time and location
- Color coding (past = gray, today = primary, upcoming = primary container)
- "My Event" badge for creator

### Event Details
- Gradient header with date/time
- Full description
- Location card (clickable to view on map - coming soon)
- Organizer information
- Edit/Delete actions for creator

### Create/Edit Form
- Title and description fields
- Date picker (future dates only)
- Time picker
- Campus location dropdown
- Custom location text field
- Cancel and Save buttons

---

## Testing Steps

### 1. Test as Student
1. Login as a student
2. Navigate to Events tab
3. ✅ Should see all events
4. ✅ Should NOT see "+" FAB button
5. Tap an event card
6. ✅ Should see event details
7. ✅ Should NOT see Edit/Delete buttons

### 2. Test as Faculty
1. Login as faculty
2. Navigate to Events tab
3. ✅ Should see "+" FAB button
4. Tap "+" to create event
5. Fill in event details
6. ✅ Should create successfully
7. ✅ New event appears in list with "My Event" badge
8. Tap the event
9. ✅ Should see Edit and Delete buttons
10. Tap Edit
11. ✅ Should pre-fill form with event data
12. Modify and save
13. ✅ Should update successfully
14. Tap Delete
15. ✅ Should show confirmation dialog
16. Confirm
17. ✅ Event removed from list

### 3. Test Filters
1. Tap filter icon in app bar
2. Select "Upcoming"
3. ✅ Should show only future events
4. Select "Today"
5. ✅ Should show only today's events
6. Select "Past Events"
7. ✅ Should show only past events
8. Select "All Events"
9. ✅ Should show all events

### 4. Test Pull-to-Refresh
1. Pull down on events list
2. ✅ Should show loading indicator
3. ✅ Should refresh event data

### 5. Test RLS (Backend Security)
Try to bypass UI restrictions:
1. As student, try to call create event API directly
2. ✅ Should be rejected by RLS
3. As faculty, try to edit another faculty's event
4. ✅ Should be rejected by RLS

---

## Known Issues / Limitations

1. **Location link**: Tapping location in event details shows snackbar but doesn't navigate to map yet (requires Phase 7 routing)
2. **Notifications**: Creating/editing events doesn't send notifications yet (Phase 6)
3. **Image upload**: Events don't support images yet
4. **RSVP**: No RSVP functionality yet

---

## Next Steps

After testing Phase 4, proceed to:
- **Phase 5**: Faculty Directory Module
- **Phase 6**: Search & Notifications
- **Phase 7**: UI/UX Design & Navigation improvements
- **Phase 8**: Testing, Optimization & Deployment

---

## Troubleshooting

### Events Not Loading
- Check Supabase connection
- Verify RLS policies are enabled
- Check console for errors

### Can't Create Event as Faculty
- Verify user role is 'faculty' in database
- Check RLS policy: `SELECT * FROM users WHERE id = auth.uid();`
- Ensure auth.uid() is set correctly

### Events Show but No Details
- Check if `created_by_user` relationship is working
- Verify users table has matching records
- Check location_id references valid campus_locations

### Date/Time Not Saving Correctly
- Check timezone settings
- Verify DateTime serialization
- Check Supabase column type is `timestamp with time zone`

---

## Code Quality

- ✅ Clean architecture (data/domain/presentation)
- ✅ Provider state management
- ✅ Repository pattern with caching
- ✅ Form validation
- ✅ Error handling
- ✅ Loading states
- ✅ Responsive UI
- ✅ Material 3 design
- ✅ Role-based access control

---

Last Updated: 2024
Phase 4 Status: ✅ COMPLETE
