import 'package:flutter/foundation.dart';
import '../../core/models/user_model.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils.dart';
import '../../features/auth/data/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final StorageService _storageService = StorageService.instance;

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isStudent => _currentUser?.isStudent ?? false;
  bool get isFaculty => _currentUser?.isFaculty ?? false;

  AuthProvider() {
    _isLoading = true; // Set loading state immediately
    // Delay initialization to ensure Supabase is ready
    Future.delayed(Duration.zero, () {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    try {
      // Check if user is already logged in
      if (_authRepository.isAuthenticated()) {
        final userId = _authRepository.getCurrentUserId();
        if (userId != null) {
          _currentUser = await _authRepository.getUserProfile(userId);
        }
      }
      
      // Done loading
      _isLoading = false;
      notifyListeners();

      // Listen to auth state changes
      _authRepository.authStateChanges().listen((authState) {
        if (authState.session == null) {
          _currentUser = null;
          notifyListeners();
        }
      });
    } catch (e) {
      // Handle initialization errors gracefully
      AppLogger.logError('Auth provider initialization error', error: e);
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign up
  Future<String> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String? department,
    String? office,
    String? officeHours,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authRepository.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
        department: department,
        office: office,
        officeHours: officeHours,
      );

      if (user != null) {
        // User is logged in immediately (email confirmation disabled)
        _currentUser = user;
        await _saveUserData(user);
        _setLoading(false);
        notifyListeners();
        return 'success';
      } else {
        // Email confirmation required
        _setLoading(false);
        return 'confirmation_required';
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return 'error';
    }
  }

  // Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        await _saveUserData(user);
        _setLoading(false);
        notifyListeners();
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);

    try {
      await _authRepository.signOut();
      await _clearUserData();
      _currentUser = null;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Update profile
  Future<bool> updateProfile({
    String? name,
    String? department,
    String? office,
    String? officeHours,
    String? profilePic,
  }) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final updatedUser = await _authRepository.updateProfile(
        userId: _currentUser!.id,
        name: name,
        department: department,
        office: office,
        officeHours: officeHours,
        profilePic: profilePic,
      );

      if (updatedUser != null) {
        _currentUser = updatedUser;
        await _saveUserData(updatedUser);
        _setLoading(false);
        notifyListeners();
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  Future<void> _saveUserData(AppUser user) async {
    await _storageService.saveUserId(user.id);
    await _storageService.saveUserRole(user.role);
  }

  Future<void> _clearUserData() async {
    await _storageService.clearAuthData();
  }
}
