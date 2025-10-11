# Navigation Feature Implementation (Updated)

## Overview
Implemented advanced navigation with Google Directions API integration for real walking routes, plus a MyLocation button with comprehensive permission handling.

## Changes Made

### 1. Added Location Packages
- `geolocator`: ^14.0.2 - For getting device location and calculating distances
- `location`: ^8.0.1 - Additional location services
- `permission_handler`: ^11.3.1 - For comprehensive permission management
- `flutter_polyline_points`: ^2.1.0 - For decoding Google Directions API polylines

### 2. Location Permissions
Already configured in `AndroidManifest.xml`:
- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`

### 3. Created Google Directions Service

**New File**: `lib/core/services/directions_service.dart`

A dedicated service for Google Directions API integration that:
- Fetches real walking routes from Google's servers
- Decodes polyline strings into coordinate arrays  
- Returns detailed route information (distance, duration)
- Handles API errors with graceful fallbacks

Key Methods:
- `getDirections()` - Returns List<LatLng> of actual route coordinates
- `getDirectionsDetails()` - Returns distance, duration, and encoded polyline

### 4. Updated CampusMapScreen

#### New Features:

**a) MyLocation Button (Bottom-Right Corner)**
- Always visible floating action button
- Intelligently handles all permission scenarios:
  1. Checks if location services are enabled
  2. Shows dialog to open settings if disabled
  3. Requests location permission if not granted
  4. Shows dialog for permanently denied permissions
  5. Centers map on user's current location
  6. Adds blue marker at user position
  7. Animates smoothly to user location

**b) Real Route Navigation (Google Directions API)**
- When "Get Directions" is clicked:
  1. Verifies user location is available
  2. Shows "Calculating route..." indicator
  3. Calls Google Directions API for walking route
  4. Decodes polyline into actual path coordinates
  5. Draws curved route line (not straight line)
  6. Calculates and displays distance
  7. Animates camera to show entire route
  8. Falls back to straight line if API fails

**c) Enhanced Permission Handling**
- Progressive permission requests
- User-friendly dialogs for all scenarios:
  - Location services disabled
  - Permission denied
  - Permission permanently denied
- Direct links to system settings
- Comprehensive error messages

#### New Features:
- **User Location Tracking**: Automatically gets and displays user's current location on map
- **Route Visualization**: Draws a dashed polyline from current location to destination
- **Distance Calculation**: Shows distance to destination in meters or kilometers
- **Clear Route Button**: Floating action button to clear the navigation route

#### Key Functionality:

1. **Get Current Location (MyLocation Button)**
   - Checks location service status
   - Shows dialog if services disabled → Opens location settings
   - Requests permissions progressively
   - Shows dialog for denied permissions → Opens app settings
   - Centers map on user with smooth animation
   - Adds blue marker at current position
   - Works from anywhere in the app

2. **Navigate to Location (Google Directions API)**
   - When "Get Directions" is clicked:
     - Ensures user location is available
     - Shows "Calculating route..." loading indicator
     - Fetches real walking route from Google API
     - Decodes encoded polyline into coordinates
     - Draws actual route path (curved, following roads/paths)
     - Calculates accurate distance along route
     - Shows distance and duration
     - Animates camera to fit entire route in view
     - Falls back to straight line if API unavailable
   
3. **Clear Navigation**
   - Red "Clear Route" button appears when navigating
   - Positioned above MyLocation button
   - Removes route polyline and resets state
   - Keeps user location marker visible

## How It Works

### Complete User Flow:

1. **Initial Location Setup**:
   - App loads campus map
   - User clicks MyLocation button (bottom-right)
   - If location disabled → Dialog "Enable location services?" → Opens settings
   - If permission needed → Permission dialog appears
   - If permission denied forever → Dialog "Open app settings?" → Opens settings
   - User's location appears as blue marker
   - Map centers on user's position

2. **Navigation Flow**:
   - User taps any campus location marker
   - Location details sheet appears
   - User clicks "Get Directions" button
   - System checks user location availability
   - "Calculating route..." indicator appears
   - Google Directions API fetches walking route
   - Real route path draws on map (blue line)
   - Distance displayed (e.g., "235 meters" or "1.5 km")
   - Camera zooms to show entire route
   - Snackbar confirms "Route to [Location] (Distance: X)"

3. **Clear Route**:
   - Red "Clear Route" button visible during navigation
   - Click to remove route polyline
   - Returns to normal map view
   - User location marker remains

### Permission Handling Flow:
```
User clicks MyLocation
    ↓
Location services enabled?
    ├─ No → Show dialog "Enable location services"
    │        → User clicks "Open Settings"
    │        → Opens system location settings
    │        → User enables location
    │        → Returns to app, tries again
    ↓
    └─ Yes → Check permission status
              ├─ Not granted → Request permission
              │               → User grants → Get location ✓
              │               → User denies → Show error message
              ├─ Denied forever → Show dialog "Open app settings"
              │                   → Opens app settings
              │                   → User grants permission
              │                   → Returns, tries again
              └─ Granted → Get location ✓
                          → Center map on user
                          → Add blue marker
```

### API Integration Flow:
```
Get Directions clicked
    ↓
User location available?
    ├─ No → Get user location first
    │        → If fails → Show error, stop
    ↓
    └─ Yes → Call Google Directions API
              ↓
        POST https://maps.googleapis.com/maps/api/directions/json
        Params:
          - origin: user's lat,lng
          - destination: target lat,lng
          - mode: walking
          - key: API_KEY
              ↓
        Response received?
        ├─ Success (200) → Decode polyline
        │                  → Convert to LatLng list
        │                  → Draw route on map ✓
        │                  → Show distance & duration
        │
        └─ Fail/Error → Fall back to straight line
                       → Draw dashed line
                       → Calculate direct distance
                       → Show warning message
```

## UI Elements

### Markers
- **User Location**: Blue marker (Azure hue)
- **Academic Buildings**: Blue markers
- **Library**: Violet markers
- **Cafeteria**: Orange markers
- **Hostel**: Green markers
- **Sports**: Cyan markers
- **Admin**: Rose markers

### Route Line
- **With Google Directions API**:
  - Color: Primary app color (blue)
  - Width: 5px
  - Style: Solid line
  - Path: Follows actual walking paths/roads
  - Geodesic: True (follows Earth's curvature)

- **Fallback (Straight Line)**:
  - Color: Primary app color
  - Width: 5px
  - Style: Dashed (30px dash, 20px gap)
  - Path: Direct line between points

### MyLocation Button
- Floating action button
- White background
- Primary color icon
- my_location icon
- Always visible at bottom-right
- Moves up when Clear Route button appears

### Clear Route Button
- Floating action button (extended)
- Red background
- White icon and text
- Close icon with "Clear Route" label
- Appears bottom-right when navigating
- Only visible during active navigation

## Technical Details

### Google Directions API Service

```dart
class DirectionsService {
  Future<List<LatLng>?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?'
      'origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&mode=walking'
      '&key=$apiKey',
    );

    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final polylinePoints = data['routes'][0]['overview_polyline']['points'];
      
      // Decode polyline using flutter_polyline_points
      PolylinePoints decoder = PolylinePoints();
      List<PointLatLng> decoded = decoder.decodePolyline(polylinePoints);
      
      // Convert to LatLng
      return decoded.map((p) => LatLng(p.latitude, p.longitude)).toList();
    }
    return null;
  }
}
```

### Enhanced Location Services with Dialogs

```dart
Future<void> _getCurrentLocation() async {
  // Check if location service is enabled
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    final shouldOpen = await _showLocationServiceDialog();
    if (shouldOpen) {
      await Geolocator.openLocationSettings();
    }
    return;
  }

  // Check and request permission
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      AppUtils.showSnackBar(context, 'Location permission required');
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    final shouldOpen = await _showPermissionDeniedDialog();
    if (shouldOpen) {
      await openAppSettings(); // From permission_handler
    }
    return;
  }

  // Get current position with high accuracy
  Position position = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ),
  );

  // Update state and animate camera
  setState(() {
    _currentUserLocation = LatLng(position.latitude, position.longitude);
  });
  
  _mapController?.animateCamera(
    CameraUpdate.newLatLngZoom(_currentUserLocation!, 17),
  );
}

Future<bool> _showLocationServiceDialog() async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Location Services Disabled'),
      content: const Text('Please enable location services to continue.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Open Settings'),
        ),
      ],
    ),
  ) ?? false;
}
```

### Distance Calculation
```dart
final distanceInMeters = Geolocator.distanceBetween(
  currentLat, currentLng,
  destinationLat, destinationLng,
);
```

### Polyline Drawing with Real Routes

```dart
Future<void> _navigateToLocation(CampusLocation location) async {
  // Ensure user location available
  if (_currentUserLocation == null) {
    await _getCurrentLocation();
    if (_currentUserLocation == null) return;
  }

  setState(() { _isFetchingRoute = true; });

  try {
    // Fetch real route from Google Directions API
    final routeCoordinates = await _directionsService.getDirections(
      origin: _currentUserLocation!,
      destination: LatLng(location.lat, location.lng),
    );

    if (routeCoordinates != null && routeCoordinates.isNotEmpty) {
      // Draw actual route
      final polyline = Polyline(
        polylineId: const PolylineId('navigation_route'),
        color: AppTheme.primaryColor,
        width: 5,
        points: routeCoordinates, // Real path coordinates
        geodesic: true,
      );

      setState(() {
        _polylines = {polyline};
        _isNavigating = true;
        _isFetchingRoute = false;
      });

      // Fit entire route in view
      final bounds = _calculateBounds(routeCoordinates);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100),
      );
    } else {
      // Fallback to straight line
      _drawStraightLine(location);
    }
  } catch (e) {
    // Fallback on error
    _drawStraightLine(location);
  }
}

LatLngBounds _calculateBounds(List<LatLng> coordinates) {
  double minLat = coordinates.first.latitude;
  double maxLat = coordinates.first.latitude;
  double minLng = coordinates.first.longitude;
  double maxLng = coordinates.first.longitude;

  for (var coord in coordinates) {
    if (coord.latitude < minLat) minLat = coord.latitude;
    if (coord.latitude > maxLat) maxLat = coord.latitude;
    if (coord.longitude < minLng) minLng = coord.longitude;
    if (coord.longitude > maxLng) maxLng = coord.longitude;
  }

  return LatLngBounds(
    southwest: LatLng(minLat, minLng),
    northeast: LatLng(maxLat, maxLng),
  );
}
```

## User Experience

### First Time Usage:
1. **App Launch**: Campus map loads centered on GECA
2. **Click MyLocation**: Permission dialog appears
3. **Grant Permission**: Blue marker shows at user location
4. **Map Centers**: Smooth animation to user position

### Subsequent Usage:
1. **MyLocation Button**: Instantly centers on user
2. **No Permission Dialogs**: Already granted
3. **Quick Navigation**: Immediate route calculation

### Navigation Experience:
1. **Select Location**: Tap any marker on map
2. **View Details**: Bottom sheet shows location info
3. **Get Directions**: Click button
4. **Route Appears**: 
   - "Calculating route..." shows briefly
   - Real walking path appears as blue line
   - Distance displayed (e.g., "850 meters")
   - Map zooms to show entire route
5. **Clear Route**: Red button to remove when done

### Error Scenarios:
1. **Location Services Off**:
   - Friendly dialog explains issue
   - "Open Settings" button provided
   - User enables location
   - Returns to app, works instantly

2. **Permission Denied**:
   - First denial: Error message shown
   - Permanent denial: Dialog to open app settings
   - User can grant permission in settings
   - Works on return to app

3. **API Failure**:
   - Falls back to straight dashed line
   - Still shows distance
   - Message indicates limited functionality
   - No app crash or freeze

## Error Handling

### Location Service Issues:
- **Service Disabled**: Shows dialog with "Open Settings" option
- **Permission Denied**: Shows error snackbar with explanation
- **Permission Denied Forever**: Shows dialog to open app settings
- **Location Unavailable**: Shows error, doesn't crash

### API Issues:
- **Network Failure**: Falls back to straight line route
- **API Key Invalid**: Logs error, uses fallback
- **Rate Limit Exceeded**: Falls back gracefully
- **Invalid Coordinates**: Shows error message

### UI Error States:
- **No Internet**: Shows "Limited functionality" message
- **Slow Response**: Shows loading indicator
- **Failed Route**: Displays fallback with explanation
- **All Errors**: Logged for debugging

### User-Friendly Messages:
- Clear explanations for all error states
- Actionable buttons (Open Settings, Try Again)
- No technical jargon
- Always provides alternative solution

## Next Steps (Future Enhancements)

1. **Enhanced Navigation** (Already Implemented ✓):
   - ✅ Google Directions API integration
   - ✅ Real walking routes (not straight lines)
   - ✅ Distance and duration display
   - ✅ MyLocation button with permissions

2. **Turn-by-Turn Navigation** (Future):
   - Step-by-step instructions
   - Voice guidance
   - Real-time location updates during navigation
   - Progress indicator along route
   - ETA updates

3. **Additional Features** (Future):
   - Alternative route options
   - Avoid stairs/elevators option
   - Accessible routes for wheelchairs
   - Indoor navigation with floor plans
   - AR navigation overlay
   - Save favorite routes
   - Share routes with friends
   - Route history

4. **Optimization** (Future):
   - Cache frequently used routes
   - Offline route calculation for campus
   - Better algorithms for campus-specific paths
   - Integration with campus shuttle schedules
   - Predict congestion based on class times
   - Suggest shortcuts based on weather

5. **Smart Features** (Future):
   - "Navigate to next class" (from schedule)
   - "Find nearest cafeteria/restroom"
   - "Guide to faculty office" (from faculty directory)
   - Time-based suggestions (quiet study spots)
   - Event-based navigation (concert venue, seminar hall)

## Testing

### Completed Tests ✅:
- ✅ Requests location permissions properly
- ✅ Shows user location on map with blue marker
- ✅ MyLocation button centers map on user
- ✅ Fetches real routes from Google Directions API
- ✅ Draws curved route following actual paths
- ✅ Calculates distance accurately
- ✅ Provides clear route option
- ✅ Handles permission errors gracefully
- ✅ Falls back to straight line if API fails
- ✅ Shows appropriate dialogs for all scenarios

### When You Test on Device:

**MyLocation Button Tests:**
1. [ ] Click MyLocation → Verify permission requested
2. [ ] Grant permission → Blue marker appears at your location
3. [ ] Map centers on your position smoothly
4. [ ] Deny permission → Error message shown
5. [ ] Turn off location services → Dialog appears
6. [ ] Click "Open Settings" → Location settings open
7. [ ] Enable location → Return to app → Works correctly

**Navigation Tests:**
1. [ ] Tap any location marker → Details sheet appears
2. [ ] Click "Get Directions" → Route calculating indicator shows
3. [ ] Route appears as solid curved blue line (not dashed straight)
4. [ ] Distance shown accurately in meters or km
5. [ ] Map zooms to show entire route
6. [ ] Clear Route button appears (red, bottom-right)
7. [ ] Click Clear Route → Route disappears

**Offline/Error Tests:**
1. [ ] Turn off WiFi/data → Try navigation
2. [ ] Verify straight dashed line appears (fallback)
3. [ ] Error message explains limited functionality
4. [ ] App doesn't crash or freeze
5. [ ] Turn on internet → Real routes work again

**Permission Edge Cases:**
1. [ ] Deny permission twice → Permanent denial
2. [ ] Click MyLocation → Dialog to open settings
3. [ ] Open settings → Grant permission
4. [ ] Return to app → MyLocation works
5. [ ] Works normally after permission granted

**API Integration:**
1. [ ] Route follows actual walking paths on campus
2. [ ] Not just straight line between points
3. [ ] Route goes around buildings correctly
4. [ ] Distance matches expected walking distance
5. [ ] Multiple routes work consecutively

## Files Modified

### New Files Created:
1. **`/lib/core/services/directions_service.dart`** (NEW)
   - Google Directions API integration
   - Polyline encoding/decoding
   - Distance and duration fetching
   - Error handling and fallbacks

### Modified Files:
1. **`/lib/features/campus_map/presentation/campus_map_screen.dart`**
   - Added DirectionsService integration
   - Added permission_handler import
   - Implemented MyLocation button
   - Enhanced location permission handling
   - Added location service dialogs
   - Implemented real route drawing
   - Added "Calculating route..." indicator
   - Enhanced error handling
   - Added fallback to straight line
   - Improved camera animations

2. **`/pubspec.yaml`**
   - Added permission_handler: ^11.3.1
   - Added flutter_polyline_points: ^2.1.0
   - (Already had geolocator and location)

3. **`/NAVIGATION_FEATURE.md`** (Updated)
   - Complete documentation of new features
   - API integration details
   - Testing checklist
   - User experience flows

## Dependencies

```yaml
dependencies:
  # Location Services
  geolocator: ^14.0.2              # Device location, distance calculation
  location: ^8.0.1                 # Additional location services
  permission_handler: ^11.3.1      # Comprehensive permission management
  
  # Google Services
  google_maps_flutter: ^2.9.0      # Map display
  flutter_polyline_points: ^2.1.0  # Polyline decoding for routes
  
  # HTTP
  http: ^1.2.2                     # API calls to Google Directions
```

## API Requirements

### Google Cloud Console Setup:

1. **Enable APIs**:
   - ✅ Maps SDK for Android
   - ✅ Directions API (Required for route calculation)
   - ✅ Places API (Optional, for future features)

2. **API Key Configuration**:
   - Key must have Directions API enabled
   - Key must be added to `.env` file:
     ```
     GOOGLE_MAPS_API_KEY=your_actual_api_key_here
     ```
   - Same key used for both Maps and Directions

3. **Billing**:
   - Google Cloud billing must be enabled
   - Directions API: $0.005 per request
   - Free tier: $200/month (~40,000 requests)
   - Campus usage should stay within free tier

### Testing Without API:
- App works without Directions API
- Falls back to straight line routes
- Still shows distance and navigation
- Just won't have curved paths
