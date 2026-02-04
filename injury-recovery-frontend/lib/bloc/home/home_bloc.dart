// lib/bloc/home/home_bloc.dart
// BLoC for the home screen - manages activity history and action selection

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:VOMAS/data/services/activity_history_service.dart';

import 'home_event.dart';
import 'home_state.dart';

/// BLoC for managing home screen state
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ActivityHistoryService _historyService;

  HomeBloc({ActivityHistoryService? historyService})
    : _historyService = historyService ?? ActivityHistoryService(),
      super(const HomeState()) {
    on<LoadHistoryRequested>(_onLoadHistoryRequested);
    on<ActionSelected>(_onActionSelected);
    on<ClearHistoryRequested>(_onClearHistoryRequested);
    on<RemoveHistoryItem>(_onRemoveHistoryItem);
    on<RefreshHistoryRequested>(_onRefreshHistoryRequested);
  }

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

  /// Handle action selection - add to history and trigger navigation
  Future<void> _onActionSelected(
    ActionSelected event,
    Emitter<HomeState> emit,
  ) async {
    try {
      // Add the activity to history
      final newItem = await _historyService.addActivityFromAction(
        event.actionType,
      );

      // Update state with new history and navigation flag
      final updatedHistory = [newItem, ...state.history];

      emit(
        state.copyWith(
          history: updatedHistory,
          selectedAction: event.actionType,
          shouldNavigate: true,
        ),
      );

      // Reset navigation flag after emitting
      emit(state.copyWith(shouldNavigate: false, clearSelectedAction: false));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to save activity: $e'));
    }
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
