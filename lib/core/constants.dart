// App Constants
class AppConstants {
  // App Info
  static const String appName = 'Campus Connect';
  static const String appVersion = '1.0.0';
  
  // API Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 15);
  
  // Pagination
  static const int itemsPerPage = 20;
  static const int maxSearchResults = 50;
  
  // Map Settings
  static const double defaultMapZoom = 15.0;
  static const double markerZoom = 18.0;
  
  // Cache Settings
  static const Duration cacheExpiry = Duration(hours: 24);
  
  // User Roles
  static const String roleStudent = 'student';
  static const String roleFaculty = 'faculty';
  
  // Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyThemeMode = 'theme_mode';
  
  // Notification Types
  static const String notifTypeEvent = 'event';
  static const String notifTypeAnnouncement = 'announcement';
  static const String notifTypeReminder = 'reminder';
  
  // Error Messages
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorServer = 'Server error. Please try again later.';
  static const String errorAuth = 'Authentication error. Please login again.';
  static const String errorPermission = 'You do not have permission for this action.';
  static const String errorGeneric = 'Something went wrong. Please try again.';
  
  // Success Messages
  static const String successLogin = 'Login successful';
  static const String successLogout = 'Logout successful';
  static const String successUpdate = 'Updated successfully';
  static const String successDelete = 'Deleted successfully';
  static const String successCreate = 'Created successfully';
}

// Route Names
class Routes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String map = '/map';
  static const String events = '/events';
  static const String eventDetail = '/event-detail';
  static const String createEvent = '/create-event';
  static const String faculty = '/faculty';
  static const String facultyDetail = '/faculty-detail';
  static const String notifications = '/notifications';
  static const String search = '/search';
  static const String settings = '/settings';
}

// Asset Paths
class Assets {
  static const String logo = 'assets/images/logo.png';
  static const String placeholder = 'assets/images/placeholder.png';
  static const String mapMarker = 'assets/icons/map_marker.png';
  static const String eventIcon = 'assets/icons/event.png';
  static const String facultyIcon = 'assets/icons/faculty.png';
}
