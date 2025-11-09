import 'package:supabase_flutter/supabase_flutter.dart';

/// Global User Service - Singleton pattern
/// Use this to access current user ID throughout the app
class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  // Global user ID variable
  String? _userId;
  User? _currentUser;

  /// Get current user ID
  String? get userId => _userId;

  /// Get current user object
  User? get currentUser => _currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => _userId != null;

  /// Initialize user from Supabase auth
  void initUser() {
    final user = Supabase.instance.client.auth.currentUser;
    _currentUser = user;
    _userId = user?.id;
  }

  /// Set user when logging in
  void setUser(User user) {
    _currentUser = user;
    _userId = user.id;
  }

  /// Clear user when logging out
  void clearUser() {
    _currentUser = null;
    _userId = null;
  }

  /// Get user email
  String? get userEmail => _currentUser?.email;

  /// Get user metadata
  Map<String, dynamic>? get userMetadata => _currentUser?.userMetadata;
}

// Global instance for easy access
final userService = UserService();