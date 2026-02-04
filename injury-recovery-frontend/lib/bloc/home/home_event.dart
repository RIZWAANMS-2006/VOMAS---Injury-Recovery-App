// lib/bloc/home/home_event.dart
// Events for the HomeBloc

import 'package:VOMAS/data/models/action_type.dart';

/// Base class for all home events
abstract class HomeEvent {
  const HomeEvent();
}

/// Load activity history on startup
class LoadHistoryRequested extends HomeEvent {
  const LoadHistoryRequested();
}

/// User selected an action from the action cards
class ActionSelected extends HomeEvent {
  final ActionType actionType;

  const ActionSelected(this.actionType);
}

/// Clear all activity history
class ClearHistoryRequested extends HomeEvent {
  const ClearHistoryRequested();
}

/// Remove a single history item
class RemoveHistoryItem extends HomeEvent {
  final String itemId;

  const RemoveHistoryItem(this.itemId);
}

/// Refresh history (e.g., after returning from measurement screen)
class RefreshHistoryRequested extends HomeEvent {
  const RefreshHistoryRequested();
}
