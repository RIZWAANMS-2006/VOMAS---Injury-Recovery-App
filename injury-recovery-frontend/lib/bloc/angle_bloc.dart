import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:VOMAS/bloc/angle_event.dart';
import 'package:VOMAS/bloc/angle_state.dart';
import 'package:VOMAS/data/models/angles.dart';
import 'package:VOMAS/data/models/activity_history_item.dart';
import 'package:VOMAS/data/models/vomas_tasks.dart';
import 'package:VOMAS/data/services/angle_services.dart';
import 'package:VOMAS/data/services/activity_history_service.dart';

class AngleBloc extends Bloc<AngleEvent, AngleState> {
  final AngleService _angleService;
  final ActivityHistoryService _historyService;
  StreamSubscription<Angles>? _angleSubscription;

  AngleBloc(this._angleService, this._historyService)
    : super(const AngleState()) {
    on<ConnectRequested>(_onConnectRequested);
    on<DisconnectRequested>(_onDisconnectRequested);
    on<AnglesReceived>(_onAnglesReceived);
    on<TaskSelected>(_onTaskSelected);
    on<ActionSelected>(_onActionSelected);
    on<CalibrateRequested>(_onCalibrateRequested);

    // Listen to service stream with subscription management
    _subscribeToAngles();
  }

  void _subscribeToAngles() {
    _angleSubscription?.cancel();
    _angleSubscription = _angleService.angleStream.listen(
      (angles) {
        if (!isClosed) {
          add(AnglesReceived(angles));
        }
      },
      onError: (error) {
        print('AngleBloc stream error: $error');
      },
    );
  }

  Future<void> _onConnectRequested(
    ConnectRequested event,
    Emitter<AngleState> emit,
  ) async {
    emit(
      state.copyWith(
        isConnecting: true,
        connectionStatus: ConnectionStatus.connecting,
        selectedAction: event.actionName,
      ),
    );

    try {
      // Re-subscribe before connecting in case stream was recreated
      _subscribeToAngles();

      await _angleService.connect(serverUrl: event.serverUrl);

      // If action name provided, select it after connection
      if (event.actionName != null) {
        _angleService.selectAction(event.actionName!);
      }

      // Start a new session for history recording
      if (event.actionType != null) {
        _historyService.startSession(event.actionType!);
      }

      emit(
        state.copyWith(
          connectionStatus: ConnectionStatus.connected,
          isConnecting: false,
          connectionError: null,
          sessionActive: true,
          sessionReadings: 0,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          connectionStatus: ConnectionStatus.error,
          connectionError: e.toString(),
          isConnecting: false,
        ),
      );
    }
  }

  Future<void> _onDisconnectRequested(
    DisconnectRequested event,
    Emitter<AngleState> emit,
  ) async {
    // Finalize the session before disconnecting
    if (_historyService.hasActiveSession) {
      await _historyService.finalizeSession();
    }

    _angleService.disconnect();
    emit(
      state.copyWith(
        connectionStatus: ConnectionStatus.disconnected,
        connectionError: null,
        latestAngles: null,
        sessionActive: false,
        sessionReadings: 0,
      ),
    );
  }

  void _onAnglesReceived(AnglesReceived event, Emitter<AngleState> emit) {
    print(
      '🧩 BLOC: AnglesReceived event! Shoulder: ${event.angles.shoulder.angle}',
    );
    final currentAngles = event.angles;
    final isCorrect = _validateAngles(currentAngles);

    // Record data point to session
    if (_historyService.hasActiveSession) {
      _historyService.recordDataPoint(
        SessionDataPoint(
          shoulderAngle: currentAngles.shoulder.angle,
          shoulderSpeed: currentAngles.shoulder.speed,
          elbowAngle: currentAngles.elbow.angle,
          elbowSpeed: currentAngles.elbow.speed,
          wristAngle: currentAngles.wrist.angle,
          wristSpeed: currentAngles.wrist.speed,
          recordedAt: DateTime.now(),
        ),
      );
    }

    emit(
      state.copyWith(
        latestAngles: currentAngles,
        isCorrect: isCorrect,
        timestamp: DateTime.now(),
        sessionReadings: _historyService.currentSessionReadings,
      ),
    );
  }

  void _onTaskSelected(TaskSelected event, Emitter<AngleState> emit) {
    _angleService.selectAction(event.task.actionType);
    emit(state.copyWith(selectedTask: event.task));
  }

  void _onActionSelected(ActionSelected event, Emitter<AngleState> emit) {
    _angleService.selectAction(event.actionName);
    emit(state.copyWith(selectedAction: event.actionName));
  }

  void _onCalibrateRequested(
    CalibrateRequested event,
    Emitter<AngleState> emit,
  ) {
    _angleService.calibrate();
  }

  bool _validateAngles(Angles angles) {
    final task = state.selectedTask;
    if (task == null) return false;
    return task.isCorrect(angles);
  }

  @override
  Future<void> close() {
    // Finalize any active session before closing
    if (_historyService.hasActiveSession) {
      _historyService.finalizeSession();
    }
    _angleSubscription?.cancel();
    _angleService.disconnect();
    return super.close();
  }
}
