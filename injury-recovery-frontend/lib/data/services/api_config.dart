// lib/data/services/api_config.dart
// API configuration for backend communication

/// Configuration for API endpoints
class ApiConfig {
  /// Base URL for the backend API
  /// Change this when deploying to production or for different environments
  static const String baseUrl = 'http://localhost:3000';

  /// API timeout in seconds
  static const int timeoutSeconds = 30;

  /// API endpoints
  static const String activitiesEndpoint = '/api/activities';
  static const String actionsEndpoint = '/api/actions';

  /// Full URL helpers
  static String get activitiesUrl => '$baseUrl$activitiesEndpoint';
  static String get actionsUrl => '$baseUrl$actionsEndpoint';
}
