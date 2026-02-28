// lib/data/services/activity_history_service.dart
// Service for persisting activity history with backend sync and local fallback

import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_history_item.dart';
import '../models/action_type.dart';
import 'activity_api_service.dart';

/// Service for managing activity history persistence
/// Primary: Backend API, Fallback: Local SharedPreferences
/// History is scoped per-user via userId
class ActivityHistoryService {
  static const String _storageKeyPrefix = 'activity_history';
  static const int _maxHistoryItems = 100;

  SharedPreferences? _prefs;
  final ActivityApiService _apiService;

  // Flag to track if backend is available
  bool _backendAvailable = true;

  // Current user ID for scoped storage
  String? _userId;

  // Singleton pattern
  ActivityHistoryService._internal() : _apiService = ActivityApiService();
  static final ActivityHistoryService _instance =
      ActivityHistoryService._internal();
  factory ActivityHistoryService() => _instance;

  // For testing - allows injection
  ActivityHistoryService.withApiService(this._apiService);

  /// Get the storage key for the current user
  String get _storageKey {
    if (_userId != null && _userId!.isNotEmpty) {
      return '${_storageKeyPrefix}_$_userId';
    }
    return _storageKeyPrefix;
  }

  /// Set the current user ID for scoped history
  void setUserId(String userId) {
    _userId = userId;
  }

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

  /// Get all activity history items, sorted by most recent first
  /// Uses local storage only when userId is set (backend is not user-aware)
  Future<List<ActivityHistoryItem>> getHistory() async {
    // Backend is NOT user-scoped, so skip it when we have a userId
    // to ensure each user only sees their own history
    if (_userId != null && _userId!.isNotEmpty) {
      return _getFromLocalStorage();
    }

    // Only use backend when no user scoping is active (legacy mode)
    if (_backendAvailable) {
      try {
        final backendHistory = await _apiService.getActivities();
        if (backendHistory.isNotEmpty) {
          await _saveToLocalStorage(backendHistory);
          return backendHistory;
        }
      } catch (e) {
        _backendAvailable = false;
        // ignore: avoid_print
        print('Backend unavailable, using local storage: $e');
      }
    }

    return _getFromLocalStorage();
  }

  /// Add a new activity to history
  /// Uses local-only when userId is set (backend is not user-aware)
  Future<ActivityHistoryItem?> addActivity(ActionType actionType) async {
    ActivityHistoryItem? newItem;

    // When user-scoped, skip backend entirely — save locally only
    if (_userId != null && _userId!.isNotEmpty) {
      newItem = ActivityHistoryItem.fromAction(actionType);
      final localHistory = await _getFromLocalStorage();
      localHistory.insert(0, newItem);
      await _saveToLocalStorage(localHistory.take(_maxHistoryItems).toList());
      return newItem;
    }

    // Legacy mode: try backend first
    if (_backendAvailable) {
      try {
        newItem = await _apiService.createActivity(actionType);
        if (newItem != null) {
          final localHistory = await _getFromLocalStorage();
          localHistory.insert(0, newItem);
          await _saveToLocalStorage(
            localHistory.take(_maxHistoryItems).toList(),
          );
          _backendAvailable = true;
          return newItem;
        }
      } catch (e) {
        _backendAvailable = false;
        // ignore: avoid_print
        print('Backend unavailable for create, using local storage: $e');
      }
    }

    // Fallback to local creation
    newItem = ActivityHistoryItem.fromAction(actionType);
    final localHistory = await _getFromLocalStorage();
    localHistory.insert(0, newItem);
    await _saveToLocalStorage(localHistory.take(_maxHistoryItems).toList());
    return newItem;
  }

  /// Add activity (legacy method for compatibility)
  @Deprecated('Use addActivity(actionType) instead')
  Future<void> addActivityItem(ActivityHistoryItem item) async {
    final prefs = await _getPrefs();
    final currentItems = await _getFromLocalStorage();
    currentItems.insert(0, item);
    final itemsToSave = currentItems.take(_maxHistoryItems).toList();
    final jsonString = encodeHistoryList(itemsToSave);
    await prefs.setString(_storageKey, jsonString);
  }

  /// Add activity from ActionType (convenience method)
  /// Delegates to main addActivity method
  Future<ActivityHistoryItem> addActivityFromAction(ActionType action) async {
    final item = await addActivity(action);
    return item ?? ActivityHistoryItem.fromAction(action);
  }

  /// Remove a specific activity by ID
  Future<void> removeActivity(String id) async {
    final prefs = await _getPrefs();
    final items = await _getFromLocalStorage();
    items.removeWhere((item) => item.id == id);
    final jsonString = encodeHistoryList(items);
    await prefs.setString(_storageKey, jsonString);
  }

  /// Clear all activity history
  Future<void> clearHistory() async {
    final prefs = await _getPrefs();
    await prefs.remove(_storageKey);
  }

  /// Get history count
  Future<int> getHistoryCount() async {
    final items = await getHistory();
    return items.length;
  }

  /// Get filtered history by action type
  Future<List<ActivityHistoryItem>> getHistoryByActionType(
    ActionType actionType,
  ) async {
    final items = await getHistory();
    return items.where((item) => item.actionType == actionType).toList();
  }

  /// Get history for today only
  Future<List<ActivityHistoryItem>> getTodayHistory() async {
    final items = await getHistory();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return items.where((item) {
      final itemDate = DateTime(
        item.timestamp.year,
        item.timestamp.month,
        item.timestamp.day,
      );
      return itemDate.isAtSameMomentAs(today);
    }).toList();
  }

  /// Check if backend is currently available
  bool get isBackendAvailable => _backendAvailable;

  /// Reset backend availability flag (e.g., after network reconnection)
  void resetBackendAvailability() {
    _backendAvailable = true;
  }

  /// Get history from local storage
  Future<List<ActivityHistoryItem>> _getFromLocalStorage() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_storageKey) ?? '';
    if (jsonString.isEmpty) return [];
    final items = decodeHistoryList(jsonString);
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }

  /// Save history to local storage
  Future<void> _saveToLocalStorage(List<ActivityHistoryItem> items) async {
    final prefs = await _getPrefs();
    final jsonString = encodeHistoryList(items);
    await prefs.setString(_storageKey, jsonString);
  }
}
