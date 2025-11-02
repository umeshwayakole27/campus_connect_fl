# Card Border Effect Update

## Enhancement
Added subtle borders to all cards to make them stand out from the background, especially in dark mode.

## Changes Made

### 1. Regular Cards (cardDecoration)
**File:** `lib/core/theme/app_decorations.dart`

**Added:**
```dart
border: Border.all(
  color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
  width: 1,
),
```

**Effect:**
- Subtle 1px border using theme outline color
- 50% opacity for a soft look
- Automatically adapts to light/dark mode

### 2. Elevated Cards (elevatedCardDecoration)
**Added:**
```dart
border: Border.all(
  color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
  width: 1.5,
),
```

**Effect:**
- Slightly thicker 1.5px border
- 30% opacity for elevated appearance
- Works with the existing shadow for depth

### 3. Gradient Cards (gradientCardDecoration)
**Added:**
```dart
border: context != null 
  ? Border.all(
      color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.2),
      width: 1,
    )
  : null,
```

**Effect:**
- Very subtle 1px border at 20% opacity
- Won't interfere with gradient colors
- Optional (only if context is provided)

## Visual Impact

### Light Mode ☀️
- Cards have subtle grey borders
- Provides clear separation from white/light background
- Maintains clean, professional look

### Dark Mode 🌙
- Cards have subtle light borders
- Clearly distinguishes cards from dark background
- Adds definition without being harsh
- Improves visual hierarchy

## Testing

To see the update:
1. **Hot Reload**: Press `r` in the terminal (lowercase r)
2. **Or Hot Restart**: Press `R` (capital R)

Check these screens:
- ✓ Home Screen - Event cards and stats cards
- ✓ Events Tab - All event cards
- ✓ Faculty Tab - Faculty cards in both views
- ✓ Notifications - Notification cards

## Expected Results

**Before:**
- Cards blended too much with background in dark mode
- Hard to distinguish card boundaries

**After:**
✅ Cards have clear, subtle borders
✅ Better visual separation
✅ Improved depth and hierarchy
✅ Professional, polished appearance
✅ Works perfectly in both light and dark modes

---

**Status:** ✅ Complete
**Date:** November 1, 2024
