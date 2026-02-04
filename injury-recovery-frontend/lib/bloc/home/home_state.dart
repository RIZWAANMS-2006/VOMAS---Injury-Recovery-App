// lib/bloc/home/home_state.dart
// State for the HomeBloc

import 'package:VOMAS/data/models/action_type.dart';
import 'package:VOMAS/data/models/activity_history_item.dart';

/// Possible status states for the home screen
enum HomeStatus { initial, loading, loaded, error }

/// State class for the home screen
class HomeState {
  /// Current loading/error status
  final HomeStatus status;

  /// List of activity history items
  final List<ActivityHistoryItem> history;

  /// Currently selected action (if any, for navigation)
  final ActionType? selectedAction;

  /// Error message if status is error
  final String? errorMessage;

  /// Flag indicating if navigation should happen
  final bool shouldNavigate;

  /// Flag indicating if an activity is being created
  final bool isCreatingActivity;

  /// API-specific error message (for non-blocking errors)
  final String? apiError;

  /// Whether backend is available
  final bool isBackendAvailable;

  const HomeState({
    this.status = HomeStatus.initial,
    this.history = const [],
    this.selectedAction,
    this.errorMessage,
    this.shouldNavigate = false,
    this.isCreatingActivity = false,
    this.apiError,
    this.isBackendAvailable = true,
  });

  /// Create a copy with updated fields
  HomeState copyWith({
    HomeStatus? status,
    List<ActivityHistoryItem>? history,
    ActionType? selectedAction,
    String? errorMessage,
    bool? shouldNavigate,
    bool? isCreatingActivity,
    String? apiError,
    bool? isBackendAvailable,
    bool clearSelectedAction = false,
    bool clearApiError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      history: history ?? this.history,
      selectedAction: clearSelectedAction
          ? null
          : (selectedAction ?? this.selectedAction),
      errorMessage: errorMessage ?? this.errorMessage,
      shouldNavigate: shouldNavigate ?? this.shouldNavigate,
      isCreatingActivity: isCreatingActivity ?? this.isCreatingActivity,
      apiError: clearApiError ? null : (apiError ?? this.apiError),
      isBackendAvailable: isBackendAvailable ?? this.isBackendAvailable,
    );
  }

  /// Check if history is empty
  bool get hasHistory => history.isNotEmpty;

  /// Get history count
  int get historyCount => history.length;

  /// Get today's activities count
  int get todayCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return history.where((item) {
      final itemDate = DateTime(
        item.timestamp.year,
        item.timestamp.month,
        item.timestamp.day,
      );
      return itemDate.isAtSameMomentAs(today);
    }).length;
  }

  @override
  String toString() {
    return 'HomeState(status: $status, historyCount: $historyCount, selectedAction: $selectedAction)';
  }
}
