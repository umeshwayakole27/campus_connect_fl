import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants.dart';
import '../utils.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();

  StorageService._();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Secure storage methods
  Future<void> saveSecure(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      AppLogger.logError('Failed to save secure data', error: e);
      rethrow;
    }
  }

  Future<String?> getSecure(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      AppLogger.logError('Failed to read secure data', error: e);
      return null;
    }
  }

  Future<void> deleteSecure(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      AppLogger.logError('Failed to delete secure data', error: e);
    }
  }

  Future<void> clearAllSecure() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      AppLogger.logError('Failed to clear secure storage', error: e);
    }
  }

  // Auth token methods
  Future<void> saveAuthToken(String token) async {
    await saveSecure(AppConstants.keyAuthToken, token);
  }

  Future<String?> getAuthToken() async {
    return await getSecure(AppConstants.keyAuthToken);
  }

  Future<void> deleteAuthToken() async {
    await deleteSecure(AppConstants.keyAuthToken);
  }

  // User ID methods
  Future<void> saveUserId(String userId) async {
    await saveSecure(AppConstants.keyUserId, userId);
  }

  Future<String?> getUserId() async {
    return await getSecure(AppConstants.keyUserId);
  }

  Future<void> deleteUserId() async {
    await deleteSecure(AppConstants.keyUserId);
  }

  // User Role methods
  Future<void> saveUserRole(String role) async {
    await saveSecure(AppConstants.keyUserRole, role);
  }

  Future<String?> getUserRole() async {
    return await getSecure(AppConstants.keyUserRole);
  }

  Future<void> deleteUserRole() async {
    await deleteSecure(AppConstants.keyUserRole);
  }

  // Clear all auth data
  Future<void> clearAuthData() async {
    await deleteAuthToken();
    await deleteUserId();
    await deleteUserRole();
  }
}
