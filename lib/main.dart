import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'firebase_options.dart';
import 'core/constants.dart';
import 'core/theme/m3_expressive_theme.dart';
import 'core/theme/m3_expressive_colors.dart';
import 'core/theme/m3_expressive_typography.dart';
import 'core/services/supabase_service.dart';
import 'core/utils.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/campus_map/presentation/campus_map_screen.dart';
import 'features/events/presentation/event_provider.dart';
import 'features/events/presentation/events_screen.dart';
import 'features/faculty/presentation/faculty_provider.dart';
import 'features/faculty/presentation/faculty_list_screen.dart';
import 'features/search/presentation/search_provider.dart';
import 'features/search/presentation/search_screen.dart';
import 'features/notifications/presentation/notification_provider.dart';
import 'features/notifications/presentation/notifications_screen.dart';
import 'features/home/enhanced_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Disable overflow warnings globally
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Container();
  };
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.logInfo('Firebase initialized successfully');
    
    // Initialize Supabase
    await SupabaseService.instance.initialize();
    AppLogger.logInfo('${AppConstants.appName} initialized successfully');
    
    // Run app only after successful initialization
    runApp(const CampusConnectApp());
  } catch (e, stackTrace) {
    AppLogger.logError('Failed to initialize app', error: e, stackTrace: stackTrace);
    
    // Show error screen if initialization fails
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Initialization Failed',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${e.toString()}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please check your .env file and ensure Supabase credentials are correct.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Restart app
                    main();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class CampusConnectApp extends StatelessWidget {
  const CampusConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadThemePreference()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => FacultyProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: M3ExpressiveTheme.light(),
            darkTheme: M3ExpressiveTheme.dark(),
            themeMode: themeProvider.themeMode,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show splash screen while checking auth state on app start
        if (authProvider.isLoading) {
          return const SplashScreen();
        }
        
        // Show home page if authenticated, login otherwise
        if (authProvider.isAuthenticated) {
          return const HomePage();
        }
        
        return const LoginScreen();
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 100,
              color: M3ExpressiveColors.primaryBlue,
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: M3ExpressiveTypography.headlineLarge.copyWith(
                color: M3ExpressiveColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version ${AppConstants.appVersion}',
              style: M3ExpressiveTypography.bodySmall,
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize FCM and request location permission when home page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Delay to ensure UI is fully ready and avoid overlapping dialogs
      Future.delayed(const Duration(milliseconds: 1000), () async {
        if (mounted) {
          // Request location permission first
          await _requestLocationPermission();
          // Wait before requesting notification permission to avoid overlapping dialogs
          await Future.delayed(const Duration(milliseconds: 1000));
          if (mounted) {
            context.read<NotificationProvider>().initializeFCM();
          }
        }
      });
    });
  }

  Future<void> _requestLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          // Small delay to ensure the UI is fully rendered
          await Future.delayed(const Duration(milliseconds: 300));
          await Geolocator.requestPermission();
        }
      }
    } catch (e) {
      AppLogger.logError('Failed to request location permission', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop && _selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          // Theme toggle button
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(themeProvider.getThemeIcon()),
                tooltip: themeProvider.getThemeLabel(),
                onPressed: () => themeProvider.toggleTheme(),
              );
            },
          ),
          // Notifications badge
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  if (provider.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          provider.unreadCount > 9 ? '9+' : '${provider.unreadCount}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onError,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _getSelectedPage(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'Events',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people_outlined),
            activeIcon: Icon(Icons.people),
            label: 'Faculty',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
      ),
    );
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return const CampusMapScreen();
      case 2:
        return const EventsScreen();
      case 3:
        return const FacultyListScreen();
      case 4:
        return const SearchScreen();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return EnhancedHomeScreen(
      onNavigateToTab: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }
}
