// lib/bloc/home/home_bloc.dart
// BLoC for the home screen - manages activity history and action selection

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:VOMAS/data/services/activity_history_service.dart';

import 'home_event.dart';
import 'home_state.dart';

/// BLoC for managing home screen state
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ActivityHistoryService _historyService;

  HomeBloc({ActivityHistoryService? historyService, required String userId})
    : _historyService = historyService ?? ActivityHistoryService(),
      super(const HomeState()) {
    // Set the user ID for scoped history storage
    _historyService.setUserId(userId);

    on<LoadHistoryRequested>(_onLoadHistoryRequested);
    on<ActionSelected>(_onActionSelected);
    on<ClearHistoryRequested>(_onClearHistoryRequested);
    on<RemoveHistoryItem>(_onRemoveHistoryItem);
    on<RefreshHistoryRequested>(_onRefreshHistoryRequested);
  }

  /// Expose the history service for session management in MeasurementScreen
  ActivityHistoryService get historyService => _historyService;

  /// Initialize the service and load history
  Future<void> _onLoadHistoryRequested(
    LoadHistoryRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.loading));

    try {
      await _historyService.init();
      final history = await _historyService.getHistory();

      emit(state.copyWith(status: HomeStatus.loaded, history: history));
    } catch (e) {
      emit(
        state.copyWith(
          status: HomeStatus.error,
          errorMessage: 'Failed to load history: $e',
        ),
      );
    }
  }

  /// Handle action selection - navigate to measurement screen only
  /// History is now created on Connect in the MeasurementScreen/AngleBloc
  Future<void> _onActionSelected(
    ActionSelected event,
    Emitter<HomeState> emit,
  ) async {
    // Only set navigation flag, do NOT create history here
    // History will be created when user presses Connect in MeasurementScreen
    emit(
      state.copyWith(selectedAction: event.actionType, shouldNavigate: true),
    );

    // Reset navigation flag after emitting
    emit(state.copyWith(shouldNavigate: false, clearSelectedAction: false));
  }

  /// Clear all history
  Future<void> _onClearHistoryRequested(
    ClearHistoryRequested event,
    Emitter<HomeState> emit,
  ) async {
    try {
      await _historyService.clearHistory();
      emit(state.copyWith(history: []));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to clear history: $e'));
    }
  }

  /// Remove a single history item
  Future<void> _onRemoveHistoryItem(
    RemoveHistoryItem event,
    Emitter<HomeState> emit,
  ) async {
    try {
      await _historyService.removeActivity(event.itemId);

      final updatedHistory = state.history
          .where((item) => item.id != event.itemId)
          .toList();

      emit(state.copyWith(history: updatedHistory));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to remove item: $e'));
    }
  }

  /// Refresh history (called when returning to home screen)
  Future<void> _onRefreshHistoryRequested(
    RefreshHistoryRequested event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final history = await _historyService.getHistory();
      emit(state.copyWith(history: history));
    } catch (e) {
      // Silent fail on refresh - keep existing data
    }
  }
}
