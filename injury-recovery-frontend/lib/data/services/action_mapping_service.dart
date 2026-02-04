// lib/data/services/action_mapping_service.dart
// Service for fetching and caching action-measurement mappings

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'activity_api_service.dart';
import '../models/action_measurement_mapping.dart';
import '../models/action_type.dart';

/// Service for managing action → measurement mappings
/// Fetches from backend and caches locally
class ActionMappingService {
  static const String _cacheKey = 'action_mappings_cache';

  final ActivityApiService _apiService;
  SharedPreferences? _prefs;

  // In-memory cache
  Map<String, Map<String, String>>? _cachedMappings;

  // Singleton pattern
  static final ActionMappingService _instance =
      ActionMappingService._internal();
  factory ActionMappingService() => _instance;
  ActionMappingService._internal() : _apiService = ActivityApiService();

  /// Initialize SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    // Try to load from local cache first
    await _loadFromCache();
  }

  /// Fetch mappings from backend and cache
  Future<Map<String, Map<String, String>>?> fetchMappings() async {
    // Try to fetch from backend
    final mappings = await _apiService.getActionMappings();

    if (mappings != null) {
      _cachedMappings = mappings;
      await _saveToCache(mappings);
      return mappings;
    }

    // If fetch fails, return cached version
    return _cachedMappings;
  }

  /// Get cached mappings (synchronous)
  Map<String, Map<String, String>>? get cachedMappings => _cachedMappings;

  /// Check if mappings are available
  bool get hasMappings => _cachedMappings != null;

  /// Get measurement for a specific action from backend mapping
  /// Falls back to local mapping if backend mapping unavailable
  ActionMeasurement getMeasurementForAction(ActionType action) {
    if (_cachedMappings != null) {
      final actionName = action.displayName;
      final mapping = _cachedMappings![actionName];

      if (mapping != null) {
        return ActionMeasurement(
          shoulder: _parseMeasurementType(mapping['shoulder']),
          elbow: _parseMeasurementType(mapping['elbow']),
          wrist: _parseMeasurementType(mapping['wrist']),
        );
      }
    }

    // Fallback to local hardcoded mapping
    return actionMeasurementMapping[action] ??
        const ActionMeasurement(
          shoulder: MeasurementType.roll,
          elbow: MeasurementType.roll,
          wrist: MeasurementType.roll,
        );
  }

  /// Parse measurement type from string
  MeasurementType _parseMeasurementType(String? value) {
    switch (value?.toLowerCase()) {
      case 'roll':
        return MeasurementType.roll;
      case 'pitch':
        return MeasurementType.pitch;
      case 'yaw':
        return MeasurementType.yaw;
      default:
        return MeasurementType.roll;
    }
  }

  /// Load mappings from local cache
  Future<void> _loadFromCache() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_cacheKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        _cachedMappings = decoded.map(
          (key, value) => MapEntry(key, Map<String, String>.from(value as Map)),
        );
      }
    } catch (e) {
      // Ignore cache load errors
      // ignore: avoid_print
      print('Failed to load mappings from cache: $e');
    }
  }

  /// Save mappings to local cache
  Future<void> _saveToCache(Map<String, Map<String, String>> mappings) async {
    try {
      final prefs = await _getPrefs();
      final jsonString = jsonEncode(mappings);
      await prefs.setString(_cacheKey, jsonString);
    } catch (e) {
      // Ignore cache save errors
      // ignore: avoid_print
      print('Failed to save mappings to cache: $e');
    }
  }

  /// Get SharedPreferences instance
  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }
}
