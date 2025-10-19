# Campus Connect

A comprehensive Flutter-based mobile application for campus navigation, event discovery, and faculty information management. Built with Flutter, Supabase (PostgreSQL), Google Maps API, and Firebase Cloud Messaging.

## 🚀 Features

### For Students
- 🗺️ **Interactive Campus Map** - Navigate campus with Google Maps integration
- 📅 **Event Discovery** - Browse and search campus events
- 👥 **Faculty Directory** - Find faculty members with office locations and hours
- 🔔 **Push Notifications** - Receive updates about campus events and announcements
- 🔍 **Global Search** - Search across events, faculty, and locations

### For Faculty
- ➕ **Event Management** - Create, edit, and delete campus events
- 📢 **Notifications** - Send announcements to students
- 📍 **Location Management** - Manage campus locations and buildings
- 👤 **Profile Management** - Update office hours and contact information

## 🏗️ Architecture

This project follows **Clean Architecture** principles with feature-based organization:

```
lib/
├── core/                    # Core utilities and shared code
│   ├── constants.dart      # App constants and routes
│   ├── theme.dart          # Material 3 theme
│   ├── utils.dart          # Utility functions
│   ├── models/             # Data models
│   ├── services/           # Core services
│   └── widgets/            # Shared widgets
├── features/               # Feature modules
│   ├── auth/              # Authentication
│   ├── campus_map/        # Map functionality
│   ├── events/            # Event management
│   ├── faculty/           # Faculty directory
│   ├── notifications/     # Push notifications
│   └── search/            # Global search
└── routes/                # Navigation configuration
```

## 📋 Prerequisites

- Flutter SDK (^3.9.2)
- Dart SDK
- Supabase account
- Google Maps API key
- Firebase project (for push notifications)

## 🛠️ Setup Instructions

### 1. Clone and Install Dependencies

```bash
# Clone the repository
git clone <your-repo-url>
cd campus_connect_fl

# Install Flutter dependencies
flutter pub get
```

### 2. Configure Environment Variables

Create a `.env` file in the root directory:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

### 3. Set Up Supabase Backend

Create a Supabase project and set up:
- Database schema (users, events, faculty, campus_locations, notifications tables)
- Row Level Security (RLS) policies
- Enable email/password authentication
- Configure storage buckets for images

### 4. Configure Google Maps

#### Android
Add your API key to `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

#### iOS
Add your API key to `ios/Runner/AppDelegate.swift`:

```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

### 5. Configure Firebase (Optional - for Push Notifications)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

### 6. Generate Code (for JSON serialization)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🚦 Running the App

```bash
# Run on connected device/emulator
flutter run

# Run in release mode
flutter run --release

# Run on specific device
flutter run -d <device_id>
```

## 📦 Dependencies

### Core Dependencies
- `supabase_flutter` - Backend and authentication
- `google_maps_flutter` - Maps integration
- `firebase_messaging` - Push notifications
- `provider` - State management
- `flutter_secure_storage` - Secure data storage
- `go_router` - Navigation
- `cached_network_image` - Image caching

### Development Dependencies
- `flutter_lints` - Code quality
- `build_runner` - Code generation
- `json_serializable` - JSON serialization
- `mockito` - Testing

See [pubspec.yaml](pubspec.yaml) for complete list.

## 🔐 Security Features

- **Row Level Security (RLS)** - Database-level security policies
- **Role-Based Access Control** - Faculty vs Student permissions
- **Secure Token Storage** - Encrypted credential storage
- **Environment Variables** - API keys and secrets protected
- **Input Validation** - Client and server-side validation

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/core/services/auth_service_test.dart
```

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Linux
- ✅ macOS
- ✅ Windows

## ✅ Development Status

**Overall Progress: 98% Complete** - Ready for production deployment!

All core features completed:
- ✅ Authentication & User Management
- ✅ Campus Map & Navigation
- ✅ Event Management
- ✅ Faculty Directory
- ✅ Global Search
- ✅ Push Notifications
- ✅ UI/UX Design & Polish

See [features.md](features.md) for detailed feature list and descriptions.

## 📚 Documentation

 - [features.md](features.md) - Complete feature list and descriptions 
- [pubspec.yaml](pubspec.yaml) - Dependencies and project configuration

## 🔄 Database Schema

### Main Tables
- `users` - User profiles with role-based access (student/faculty)
- `events` - Campus events with categories and RSVP tracking
- `faculty` - Faculty information with departments and office hours
- `campus_locations` - Campus buildings and facilities with coordinates
- `notifications` - Push notifications and announcements

## 🎨 Design System

- **UI Framework**: Material Design 3
- **Theme**: Light and Dark mode support
- **Colors**: Primary (Blue), Secondary (Green), Accent (Orange)
- **Typography**: Material Typography Scale

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👥 Authors

- [umeshwayakole27](https://github.com/umeshwayakole27)- Initial work

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for the backend platform
- Google Maps for navigation services
- Firebase for push notifications

## 📞 Support

For issues and questions:
- Open an issue on GitHub
- Check [features.md](features.md) for feature documentation

## 🔮 Upcoming Features

See [features.md](features.md) for complete list of upcoming features including:
- Real-time event updates
- Chat functionality
- Resource booking system
- Analytics dashboard
- Multi-language support

---

**Note**: Before running the app, ensure you've set up your Supabase project with the required database schema and configured your `.env` file with valid credentials.
