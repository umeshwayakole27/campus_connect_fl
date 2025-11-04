# Campus Connect 🎓

A comprehensive Flutter-based mobile application for campus navigation, event discovery, and faculty information management.

![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.3+-0175C2?logo=dart)
![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)
![Firebase](https://img.shields.io/badge/Firebase-FCM-FFCA28?logo=firebase)

## 📱 Overview

Campus Connect enhances campus life by providing interactive navigation, event management, faculty directory, real-time notifications, and more.

## ✨ Key Features

### For Students
- 🗺️ Navigate campus with Google Maps and turn-by-turn directions
- 📅 Discover and register for campus events
- 👥 Find faculty with office hours and locations
- 🔔 Receive real-time push notifications
- 🔍 Search across events, faculty, and locations
- 🌓 Beautiful Material 3 UI with light/dark mode

### For Faculty
- ➕ Create and manage campus events
- 📢 Send announcements to students
- 📍 Update office hours and contact info
- 👤 Manage faculty profile

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.19+
- Dart SDK 3.3+
- Supabase account
- Firebase account
- Google Maps API key

### Installation

1. **Clone repository**
   ```bash
   git clone https://github.com/yourusername/campus_connect_fl.git
   cd campus_connect_fl
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   
   Create `.env` file:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Detailed Setup

📖 **See [SETUP.md](SETUP.md)** for complete step-by-step setup including:
- Supabase database configuration
- Firebase FCM setup
- Google Maps API configuration
- Platform-specific setup (Android/iOS)

## 📚 Documentation

- **[SETUP.md](SETUP.md)** - Complete setup guide
- **[features.md](features.md)** - Feature list and user flows

## 🏗️ Architecture

Built with **Clean Architecture** principles:

```
lib/
├── core/              # Shared utilities, models, services
├── features/          # Feature modules (auth, events, map, etc.)
│   ├── data/         # Data layer
│   └── presentation/ # UI layer
└── main.dart         # Entry point
```

**Tech Stack:**
- **Frontend**: Flutter + Provider (state management)
- **Backend**: Supabase (PostgreSQL + Real-time)
- **Notifications**: Firebase Cloud Messaging
- **Maps**: Google Maps API
- **UI**: Material Design 3 with custom theming

## 🎨 Design System

- **Material 3** expressive design language
- Dynamic light/dark theme support
- Context-aware colors using ThemeHelper
- Smooth 60 FPS animations
- Responsive layouts for all screen sizes

## 🔐 Security

- Row Level Security (RLS) at database level
- Role-based permissions (student/faculty)
- Encrypted credential storage
- Environment variable protection
- Input validation (client + server)

## 📱 Platform Support

- ✅ Android (API 21+)
- ✅ iOS (11.0+)
- ✅ Web
- ✅ Linux/macOS/Windows (Desktop)

## 🧪 Testing & Building

```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Build Android APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

## 🗺️ Roadmap

- [ ] Real-time event updates via WebSocket
- [ ] QR code attendance tracking
- [ ] Chat functionality
- [ ] Resource booking system
- [ ] Multi-language support
- [ ] Analytics dashboard

## 📊 Project Status

**Overall Completion: 98%** 🎉

- ✅ Authentication & User Management
- ✅ Campus Map & Navigation
- ✅ Event Management
- ✅ Faculty Directory
- ✅ Global Search
- ✅ Push Notifications
- ✅ Material 3 UI with theming

## 🤝 Contributing

Contributions welcome! Please submit Pull Requests.

## 📝 License

MIT License - see [LICENSE](LICENSE) file

## 📞 Support

For support or questions, create an issue on GitHub.

---

**Built with ❤️ using Flutter**
