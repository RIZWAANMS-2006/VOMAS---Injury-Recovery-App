// lib/data/services/api_service.dart
// HTTP client wrapper for REST API calls

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// Exception for API errors
class ApiException implements Exception {
  final String code;
  final String message;
  final int? statusCode;

  ApiException({required this.code, required this.message, this.statusCode});

  @override
  String toString() => 'ApiException: [$code] $message';
}

/// Standard API response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? errorCode;
  final String? errorMessage;

  ApiResponse({
    required this.success,
    this.data,
    this.errorCode,
    this.errorMessage,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? dataParser,
  ) {
    final success = json['success'] as bool? ?? false;

    if (success && dataParser != null && json['data'] != null) {
      return ApiResponse(success: true, data: dataParser(json['data']));
    }

    if (!success && json['error'] != null) {
      final error = json['error'] as Map<String, dynamic>;
      return ApiResponse(
        success: false,
        errorCode: error['code'] as String?,
        errorMessage: error['message'] as String?,
      );
    }

    return ApiResponse(success: success);
  }
}

/// HTTP client wrapper with error handling
class ApiService {
  final http.Client _client;
  final Duration _timeout;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal()
    : _client = http.Client(),
      _timeout = Duration(seconds: ApiConfig.timeoutSeconds);

  /// GET request with JSON response
  Future<ApiResponse<T>> get<T>(
    String url, {
    T Function(dynamic)? dataParser,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .get(Uri.parse(url), headers: _buildHeaders(headers))
          .timeout(_timeout);

      return _handleResponse(response, dataParser);
    } on SocketException {
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: 'Unable to connect to server. Please check your connection.',
      );
    } on TimeoutException {
      throw ApiException(
        code: 'TIMEOUT',
        message: 'Request timed out. Please try again.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'UNKNOWN_ERROR',
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// POST request with JSON body and response
  Future<ApiResponse<T>> post<T>(
    String url, {
    Map<String, dynamic>? body,
    T Function(dynamic)? dataParser,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);

      return _handleResponse(response, dataParser);
    } on SocketException {
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: 'Unable to connect to server. Please check your connection.',
      );
    } on TimeoutException {
      throw ApiException(
        code: 'TIMEOUT',
        message: 'Request timed out. Please try again.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'UNKNOWN_ERROR',
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Build headers with content type
  Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?customHeaders,
    };
  }

  /// Handle HTTP response and parse JSON
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? dataParser,
  ) {
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiResponse.fromJson(json, dataParser);
    } catch (e) {
      throw ApiException(
        code: 'PARSE_ERROR',
        message: 'Failed to parse server response',
        statusCode: response.statusCode,
      );
    }
  }

  /// Clean up resources
  void dispose() {
    _client.close();
  }
}
