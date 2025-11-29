import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils.dart';

class AuthRepository {
  final SupabaseService _supabaseService = SupabaseService.instance;
  
  SupabaseClient get _client {
    if (!_supabaseService.isInitialized) {
      throw Exception('Supabase not initialized. Call SupabaseService.instance.initialize() first.');
    }
    return _supabaseService.client;
  }

  // Sign up with email, password, and role
  Future<AppUser?> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String? department,
    String? office,
    String? officeHours,
  }) async {
    try {
      // Sign up with Supabase Auth
      // Note: emailRedirectTo is set to handle confirmation in app
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'io.supabase.campusconnect://login-callback/',
        data: {
          'name': name,
          'role': role,
          'department': department,
          'office': office,
          'office_hours': officeHours,
        },
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create user account');
      }

      // Check if email confirmation is required
      if (authResponse.session == null) {
        // Email confirmation required - user created but not logged in
        AppLogger.logInfo('User created, email confirmation required: $email');
        
        // Create user profile anyway (will be available after confirmation)
        final userData = {
          'id': authResponse.user!.id,
          'email': email,
          'name': name,
          'role': role,
          'department': department,
          'office': office,
          'office_hours': officeHours,
        };

        await _client.from('users').insert(userData);

        // If faculty, also create faculty record
        if (role == 'faculty') {
          final facultyData = {
            'user_id': authResponse.user!.id,
            'department': department ?? '',
            'designation': null,
            'office_location': office,
            'office_hours': officeHours,
            'phone': null,
          };
          
          await _client.from('faculty').insert(facultyData).select();
        }

        // Return null to indicate email confirmation needed
        return null;
      }

      // User is logged in (email confirmation disabled or auto-confirmed)
      // Create user profile in users table
      final userData = {
        'id': authResponse.user!.id,
        'email': email,
        'name': name,
        'role': role,
        'department': department,
        'office': office,
        'office_hours': officeHours,
      };

      await _client.from('users').insert(userData);

      // If faculty, also create faculty record
      if (role == 'faculty') {
        final facultyData = {
          'user_id': authResponse.user!.id,
          'department': department ?? '',
          'designation': null,
          'office_location': office,
          'office_hours': officeHours,
          'phone': null,
        };
        
        await _client.from('faculty').insert(facultyData).select();
      }

      // Fetch and return complete user profile
      return await getUserProfile(authResponse.user!.id);
    } catch (e, stackTrace) {
      AppLogger.logError('Sign up failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Login failed');
      }

      return await getUserProfile(authResponse.user!.id);
    } catch (e, stackTrace) {
      AppLogger.logError('Sign in failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get user profile from database
  Future<AppUser?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return AppUser.fromJson(response);
    } catch (e, stackTrace) {
      AppLogger.logError('Get user profile failed', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e, stackTrace) {
      AppLogger.logError('Sign out failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e, stackTrace) {
      AppLogger.logError('Reset password failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Update user profile
  Future<AppUser?> updateProfile({
    required String userId,
    String? name,
    String? department,
    String? office,
    String? officeHours,
    String? profilePic,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (department != null) updateData['department'] = department;
      if (office != null) updateData['office'] = office;
      if (officeHours != null) updateData['office_hours'] = officeHours;
      if (profilePic != null) updateData['profile_pic'] = profilePic;

      await _client
          .from('users')
          .update(updateData)
          .eq('id', userId);

      return await getUserProfile(userId);
    } catch (e, stackTrace) {
      AppLogger.logError('Update profile failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Check if user is authenticated
  bool isAuthenticated() {
    return _client.auth.currentUser != null;
  }

  // Get current user ID
  String? getCurrentUserId() {
    return _client.auth.currentUser?.id;
  }

  // Listen to auth state changes
  Stream<AuthState> authStateChanges() {
    return _client.auth.onAuthStateChange;
  }
}
