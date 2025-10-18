# Iconsax Icons - Quick Reference Guide

## 📦 Usage

```dart
import 'package:iconsax/iconsax.dart';

// Use in your widgets
Icon(Iconsax.calendar)
Icon(Iconsax.user)
Icon(Iconsax.building)
```

---

## 🎯 Common Icons Used in Campus Connect

### Navigation & UI
```dart
Iconsax.home             // Home screen
Iconsax.search_normal    // Search
Iconsax.notification     // Notifications
Iconsax.setting_2        // Settings
Iconsax.arrow_right_3    // Forward/Next
Iconsax.arrow_left_2     // Back
Iconsax.menu             // Menu
Iconsax.close_circle     // Close
```

### Events
```dart
Iconsax.calendar         // Calendar/Events
Iconsax.calendar_1       // Calendar variant
Iconsax.calendar_tick    // Event confirmed
Iconsax.book_1           // Academic events
Iconsax.music            // Cultural events
Iconsax.cup              // Sports events
Iconsax.teacher          // Workshop/Training
Iconsax.microphone       // Seminar/Talk
```

### Faculty & Users
```dart
Iconsax.user             // User profile
Iconsax.profile_2user    // Multiple users
Iconsax.teacher          // Faculty/Teacher
Iconsax.people           // Group
Iconsax.building         // Department/Building
Iconsax.building_3       // Office building
```

### Communication
```dart
Iconsax.call             // Phone
Iconsax.sms              // Email/Message
Iconsax.message_text     // Chat
Iconsax.send             // Send message
Iconsax.direct           // Direct message
```

### Location & Map
```dart
Iconsax.location         // Location pin
Iconsax.map              // Map view
Iconsax.map_1            // Map variant
Iconsax.routing          // Navigation/Route
Iconsax.gps              // GPS location
Iconsax.global           // Global/Campus
```

### Actions
```dart
Iconsax.add              // Add/Create
Iconsax.add_circle       // Add with circle
Iconsax.edit             // Edit
Iconsax.edit_2           // Edit variant
Iconsax.trash            // Delete
Iconsax.save_2           // Save
Iconsax.tick_circle      // Confirm/Done
Iconsax.close_circle     // Cancel
```

### Media & Files
```dart
Iconsax.image            // Image/Photo
Iconsax.gallery          // Gallery
Iconsax.video            // Video
Iconsax.document         // Document
Iconsax.folder           // Folder
Iconsax.archive_book     // Archive
```

### Status & Feedback
```dart
Iconsax.tick_circle      // Success
Iconsax.info_circle      // Information
Iconsax.warning_2        // Warning
Iconsax.danger           // Error/Danger
Iconsax.heart            // Like/Favorite
Iconsax.star_1           // Rating
```

### Time & Schedule
```dart
Iconsax.clock            // Time
Iconsax.timer_1          // Timer
Iconsax.calendar_2       // Schedule
Iconsax.refresh          // Refresh
Iconsax.flash_1          // Quick/Fast
```

### Academic
```dart
Iconsax.book             // Book/Course
Iconsax.book_1           // Book variant
Iconsax.note             // Notes
Iconsax.note_2           // Notes variant
Iconsax.clipboard_text   // Assignment
Iconsax.task_square      // Tasks
Iconsax.medal_star       // Achievement
```

### UI Elements
```dart
Iconsax.more             // More options (3 dots)
Iconsax.more_circle      // More in circle
Iconsax.filter           // Filter
Iconsax.sort             // Sort
Iconsax.grid_1           // Grid view
Iconsax.row_vertical     // List view
Iconsax.eye              // View/Show
Iconsax.eye_slash        // Hide
```

---

## 🎨 Icon Variants

Most Iconsax icons have multiple variants:
- `Iconsax.calendar` - Base outline
- `Iconsax.calendar_1` - Variant 1
- `Iconsax.calendar_2` - Variant 2
- Add `Bold` suffix for filled version (e.g., `IconsaxBold.calendar`)

---

## 💡 Pro Tips

### Sizing
```dart
Icon(Iconsax.calendar, size: 24)  // Default
Icon(Iconsax.calendar, size: 20)  // Small
Icon(Iconsax.calendar, size: 28)  // Large
```

### Coloring
```dart
Icon(Iconsax.calendar, color: Colors.blue)
Icon(Iconsax.calendar, color: Theme.of(context).primaryColor)
Icon(Iconsax.calendar, color: M3ExpressiveColors.primaryBlue)
```

### In Buttons
```dart
ElevatedButton.icon(
  icon: Icon(Iconsax.add),
  label: Text('Create'),
  onPressed: () {},
)
```

### In ListTiles
```dart
ListTile(
  leading: Icon(Iconsax.calendar),
  title: Text('Events'),
  trailing: Icon(Iconsax.arrow_right_3),
)
```

---

## 🔍 Finding Icons

### Online Resources
- Official Site: https://iconsax.io/
- Search by category
- Preview before using
- Copy icon name directly

### In Code
```dart
// All available in Iconsax class
// Auto-complete shows all options
Icon(Iconsax.) // <- Press Ctrl+Space here
```

---

## 📊 Categories Available

- **Arrows**: Various directional arrows
- **Business**: Office, building, briefcase
- **Communication**: Call, message, email
- **Education**: Book, teacher, student
- **Location**: Map, location, GPS
- **Media**: Image, video, gallery
- **Social**: Like, share, comment
- **Time**: Clock, calendar, timer
- **User**: Profile, people, group
- **UI**: Settings, menu, search
- **Files**: Document, folder, archive
- **Status**: Success, error, warning

---

## ✨ Examples from Campus Connect

### Event Card
```dart
Icon(Iconsax.calendar_1, size: 16)  // Date icon
Icon(Iconsax.location, size: 16)    // Location icon
Icon(Iconsax.arrow_right_3, size: 20) // View more
```

### Faculty Card
```dart
Icon(Iconsax.user, size: 28)        // Profile avatar
Icon(Iconsax.building, size: 14)    // Department
Icon(Iconsax.call, size: 16)        // Phone
Icon(Iconsax.sms, size: 16)         // Email
```

### Bottom Navigation
```dart
Icon(Iconsax.home)           // Home
Icon(Iconsax.calendar)       // Events
Icon(Iconsax.map)            // Map
Icon(Iconsax.user)           // Profile
```

### Floating Action Button
```dart
Icon(Iconsax.add)            // Create
Icon(Iconsax.edit_2)         // Edit
Icon(Iconsax.save_2)         // Save
```

---

## 🎯 Quick Copy-Paste

```dart
// Common combinations
Row(
  children: [
    Icon(Iconsax.calendar_1, size: 16),
    SizedBox(width: 6),
    Text(date),
  ],
)

// With color
Icon(
  Iconsax.tick_circle,
  color: Colors.green,
  size: 20,
)

// In Container
Container(
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.blue.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Icon(Iconsax.calendar, color: Colors.blue),
)
```

---

**More icons**: Visit https://iconsax.io/ for the complete collection!
