// lib/data/services/activity_api_service.dart
// Activity-specific API service

import 'api_config.dart';
import 'api_service.dart';
import '../models/activity_history_item.dart';
import '../models/action_type.dart';

/// Service for activity-related API calls
class ActivityApiService {
  final ApiService _apiService;

  // Singleton pattern
  static final ActivityApiService _instance = ActivityApiService._internal();
  factory ActivityApiService() => _instance;
  ActivityApiService._internal() : _apiService = ApiService();

  /// Create a new activity from an action type
  /// Returns the created activity or throws ApiException
  Future<ActivityHistoryItem?> createActivity(ActionType actionType) async {
    try {
      final response = await _apiService.post<ActivityHistoryItem>(
        ApiConfig.activitiesUrl,
        body: {'actionName': actionType.displayName},
        dataParser: (data) =>
            ActivityHistoryItem.fromApiJson(data as Map<String, dynamic>),
      );

      if (response.success && response.data != null) {
        return response.data;
      }

      // Log error but don't throw - let caller handle gracefully
      // ignore: avoid_print
      print('API Error: ${response.errorCode} - ${response.errorMessage}');
      return null;
    } on ApiException catch (e) {
      // ignore: avoid_print
      print('API Exception: ${e.code} - ${e.message}');
      return null;
    }
  }

  /// Get all activities from the backend
  Future<List<ActivityHistoryItem>> getActivities() async {
    try {
      final response = await _apiService.get<List<ActivityHistoryItem>>(
        ApiConfig.activitiesUrl,
        dataParser: (data) {
          final list = data as List<dynamic>;
          return list
              .map(
                (item) => ActivityHistoryItem.fromApiJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList();
        },
      );

      if (response.success && response.data != null) {
        return response.data!;
      }

      return [];
    } on ApiException catch (e) {
      // ignore: avoid_print
      print('API Exception: ${e.code} - ${e.message}');
      return [];
    }
  }

  /// Get the action → measurement mapping from backend
  Future<Map<String, Map<String, String>>?> getActionMappings() async {
    try {
      final response = await _apiService.get<Map<String, Map<String, String>>>(
        ApiConfig.actionsUrl,
        dataParser: (data) {
          final map = data as Map<String, dynamic>;
          return map.map(
            (key, value) =>
                MapEntry(key, Map<String, String>.from(value as Map)),
          );
        },
      );

      if (response.success && response.data != null) {
        return response.data;
      }

      return null;
    } on ApiException catch (e) {
      // ignore: avoid_print
      print('API Exception: ${e.code} - ${e.message}');
      return null;
    }
  }
}
