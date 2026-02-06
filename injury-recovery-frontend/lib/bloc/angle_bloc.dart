import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:VOMAS/bloc/angle_event.dart';
import 'package:VOMAS/bloc/angle_state.dart';
import 'package:VOMAS/data/models/angles.dart';
import 'package:VOMAS/data/models/vomas_tasks.dart';
import 'package:VOMAS/data/services/angle_services.dart';

class AngleBloc extends Bloc<AngleEvent, AngleState> {
  final AngleService _angleService;
  StreamSubscription<Angles>? _angleSubscription;

  AngleBloc(this._angleService) : super(const AngleState()) {
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

      emit(
        state.copyWith(
          connectionStatus: ConnectionStatus.connected,
          isConnecting: false,
          connectionError: null,
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
    _angleService.disconnect();
    emit(
      state.copyWith(
        connectionStatus: ConnectionStatus.disconnected,
        connectionError: null,
        latestAngles: null,
      ),
    );
  }

  void _onAnglesReceived(AnglesReceived event, Emitter<AngleState> emit) {
    print(
      '🧩 BLOC: AnglesReceived event! Shoulder: ${event.angles.shoulder.angle}',
    );
    final currentAngles = event.angles;
    final isCorrect = _validateAngles(currentAngles);

    emit(
      state.copyWith(
        latestAngles: currentAngles,
        isCorrect: isCorrect,
        timestamp: DateTime.now(),
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
    // Cancel subscription but don't dispose the singleton service
    _angleSubscription?.cancel();
    _angleService.disconnect();
    return super.close();
  }
}
