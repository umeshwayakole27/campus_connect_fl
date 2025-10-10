# Database Migration Note

## Campus Locations Table Evolution

### Initial Setup (SUPABASE_SETUP.md - Phase 1)

**Basic Structure:**
```sql
CREATE TABLE campus_locations (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  building_code TEXT,
  lat DOUBLE PRECISION NOT NULL,
  lng DOUBLE PRECISION NOT NULL,
  description TEXT,
  created_at TIMESTAMP
);
```

**Purpose:** Basic location storage for future features

---

### Phase 3 Extensions (PHASE3_SETUP.md)

**Additional Columns:**
- `category` TEXT - Location category (academic, library, cafeteria, hostel, sports, admin)
- `floor_info` TEXT - Floor information (e.g., "Ground to 4th floor")
- `image_url` TEXT - Optional image URL for location
- `updated_at` TIMESTAMP - Track last update time

**Migration Approach:**
The PHASE3_SETUP.md script uses `ALTER TABLE` to add these columns to the existing table, ensuring:
- ✅ No data loss
- ✅ Safe to run multiple times (idempotent)
- ✅ Backward compatible
- ✅ Automatic index creation

---

## How to Use

### If Starting Fresh (New Project)
1. Run SUPABASE_SETUP.md SQL first (creates basic tables)
2. When reaching Phase 3, run PHASE3_SETUP.md SQL (adds Phase 3 columns)

### If You Already Created Tables
1. Run PHASE3_SETUP.md SQL - it will:
   - Check for existing columns
   - Add only missing columns
   - Update RLS policies
   - Insert sample data (if not exists)

---

## Table Schema After Phase 3

```sql
campus_locations:
  - id (UUID, PRIMARY KEY)
  - name (TEXT, NOT NULL)
  - building_code (TEXT)
  - lat (DOUBLE PRECISION, NOT NULL)
  - lng (DOUBLE PRECISION, NOT NULL)
  - description (TEXT)
  - category (TEXT)             ← Added in Phase 3
  - floor_info (TEXT)           ← Added in Phase 3
  - image_url (TEXT)            ← Added in Phase 3
  - created_at (TIMESTAMP)
  - updated_at (TIMESTAMP)      ← Added in Phase 3
```

---

## Category Values

The following categories are used in the app:
- `academic` - Academic buildings, classrooms, labs
- `library` - Libraries, reading rooms
- `cafeteria` - Dining halls, food courts, canteens
- `hostel` - Student accommodations, dorms
- `sports` - Sports facilities, gyms, playgrounds
- `admin` - Administrative offices, departments

---

## RLS Policies

**After Phase 3:**
- Everyone can view all locations (SELECT)
- Only faculty can add/edit/delete locations (INSERT/UPDATE/DELETE)
- Enforced at database level for security

---

## Sample Data

Phase 3 includes 14 sample locations with GECA Aurangabad (Chhatrapati Sambhajinagar) campus coordinates:
1. Main Administrative Building (ADMIN) - Admin
2. Central Library (LIB) - Library
3. Computer Science & Engineering Block (CSE) - Academic
4. Electronics & Telecommunication Block (ETC) - Academic
5. Mechanical Engineering Block (MECH) - Academic
6. Civil Engineering Block (CIVIL) - Academic
7. Electrical Engineering Block (EE) - Academic
8. Student Canteen (CANTEEN) - Cafeteria
9. Workshop & Laboratory Complex (WORKSHOP) - Academic
10. Boys Hostel (BH) - Hostel
11. Girls Hostel (GH) - Hostel
12. Sports Complex (SPORTS) - Sports
13. Auditorium (AUD) - Academic
14. Training & Placement Cell (TPC) - Admin

Campus center: 19.8680°N, 75.3241°E (Aurangabad, Maharashtra)

**Note:** Update coordinates to match exact building positions on your campus!

---

## Migration Safety

The Phase 3 SQL script uses:
```sql
DO $$ BEGIN
  IF NOT EXISTS (...) THEN
    ALTER TABLE ADD COLUMN ...
  END IF;
END $$;
```

This ensures:
- No error if column already exists
- Safe to re-run the script
- No data corruption
- Production-safe migration

---

**Summary:** Run PHASE3_SETUP.md SQL script regardless of whether you created the table from SUPABASE_SETUP.md or not - it will safely handle both cases!
