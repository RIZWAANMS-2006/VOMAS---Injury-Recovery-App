// lib/data/services/user_service.dart
// Service for managing user profiles via SharedPreferences

import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Service for CRUD operations on user profiles
class UserService {
  static const String _usersKey = 'vomas_users';
  static const String _activeUserKey = 'vomas_active_user_id';

  SharedPreferences? _prefs;

  // Singleton pattern
  UserService._internal();
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;

  /// Initialize SharedPreferences instance
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Ensures prefs is initialized before any operation
  Future<SharedPreferences> _getPrefs() async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  /// Get all users
  Future<List<UserModel>> getUsers() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_usersKey) ?? '';
    if (jsonString.isEmpty) return [];
    return decodeUserList(jsonString);
  }

  /// Add a new user
  Future<UserModel> addUser(String name) async {
    final prefs = await _getPrefs();
    final users = await getUsers();
    final newUser = UserModel.create(name);
    users.add(newUser);
    await prefs.setString(_usersKey, encodeUserList(users));
    return newUser;
  }

  /// Delete a user by ID (also clears their history storage key)
  Future<void> deleteUser(String userId) async {
    final prefs = await _getPrefs();
    final users = await getUsers();
    users.removeWhere((u) => u.id == userId);
    await prefs.setString(_usersKey, encodeUserList(users));

    // Remove the user's activity history
    await prefs.remove('activity_history_$userId');

    // If the deleted user was active, clear active user
    final activeId = prefs.getString(_activeUserKey);
    if (activeId == userId) {
      await prefs.remove(_activeUserKey);
    }
  }

  /// Get the currently active user ID
  Future<String?> getActiveUserId() async {
    final prefs = await _getPrefs();
    return prefs.getString(_activeUserKey);
  }

  /// Set the active user
  Future<void> setActiveUser(String userId) async {
    final prefs = await _getPrefs();
    await prefs.setString(_activeUserKey, userId);
  }

  /// Get a user by ID
  Future<UserModel?> getUserById(String userId) async {
    final users = await getUsers();
    try {
      return users.firstWhere((u) => u.id == userId);
    } catch (_) {
      return null;
    }
  }
}
