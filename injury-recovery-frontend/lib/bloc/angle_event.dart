import 'package:VOMAS/data/models/angles.dart';
import 'package:VOMAS/data/models/vomas_task.dart';
import 'package:VOMAS/data/models/action_type.dart';

abstract class AngleEvent {}

class ConnectRequested implements AngleEvent {
  final String serverUrl;
  final String? actionName; // Action to register after connecting
  final ActionType? actionType; // ActionType for session tracking
  ConnectRequested(this.serverUrl, {this.actionName, this.actionType});
}

class DisconnectRequested implements AngleEvent {}

class AnglesReceived implements AngleEvent {
  final Angles angles;
  AnglesReceived(this.angles);
}

class TaskSelected implements AngleEvent {
  final VomasTask task;
  TaskSelected(this.task);
}

/// Event to select/change action after already connected
class ActionSelected implements AngleEvent {
  final String actionName;
  ActionSelected(this.actionName);
}

/// Event to trigger calibration on IoT device
class CalibrateRequested implements AngleEvent {}
