import 'package:VOMAS/data/models/angles.dart';
import 'package:VOMAS/data/models/vomas_task.dart';

enum ConnectionStatus { initial, connecting, connected, disconnected, error }

class AngleState {
  final ConnectionStatus connectionStatus;
  final bool isConnecting;
  final String? connectionError;
  final Map<String, Angles>? latestAngles;
  final bool isCorrect;
  final VomasTask? selectedTask;
  final DateTime? timestamp;
  final String? selectedAction;
  final bool sessionActive;
  final int sessionReadings;

  const AngleState({
    this.connectionStatus = ConnectionStatus.initial,
    this.isConnecting = false,
    this.connectionError,
    this.latestAngles,
    this.isCorrect = false,
    this.selectedTask,
    this.timestamp,
    this.selectedAction,
    this.sessionActive = false,
    this.sessionReadings = 0,
  });

  AngleState copyWith({
    ConnectionStatus? connectionStatus,
    bool? isConnecting,
    String? connectionError,
    Map<String, Angles>? latestAngles,
    bool? isCorrect,
    VomasTask? selectedTask,
    DateTime? timestamp,
    String? selectedAction,
    bool? sessionActive,
    int? sessionReadings,
  }) {
    return AngleState(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      isConnecting: isConnecting ?? this.isConnecting,
      connectionError: connectionError ?? this.connectionError,
      latestAngles: latestAngles ?? this.latestAngles,
      isCorrect: isCorrect ?? this.isCorrect,
      selectedTask: selectedTask ?? this.selectedTask,
      timestamp: timestamp ?? this.timestamp,
      selectedAction: selectedAction ?? this.selectedAction,
      sessionActive: sessionActive ?? this.sessionActive,
      sessionReadings: sessionReadings ?? this.sessionReadings,
    );
  }

  bool get hasAngles => latestAngles != null && latestAngles!.isNotEmpty;

  Angles? getAnglesForAction(String actionName) {
    return latestAngles?[actionName];
  }
  bool get isReady =>
      connectionStatus == ConnectionStatus.connected && hasAngles;
}
