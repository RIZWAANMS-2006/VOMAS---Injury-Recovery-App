// lib/services/angle_service.dart
// ignore_for_file: avoid_print

import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/angles.dart';

class AngleService {
  io.Socket? _socket;
  StreamController<Angles>? _angleController;
  bool _isConnected = false;
  Angles? _latestAngles; // Cache for synchronous access
  bool _isDisposed = false;

  // Ensure StreamController is initialized and open
  StreamController<Angles> _getAngleController() {
    if (_angleController == null || _angleController!.isClosed) {
      _angleController = StreamController<Angles>.broadcast();
    }
    return _angleController!;
  }

  // Public stream for UI to listen
  Stream<Angles> get angleStream => _getAngleController().stream;

  // Singleton pattern
  static final AngleService _instance = AngleService._internal();
  factory AngleService() => _instance;
  AngleService._internal();

  /// Connect to NestJS Socket.IO server
  Future<void> connect({required String serverUrl}) async {
    // Clean up any existing socket first
    _cleanupSocket();

    // Reset connection state
    _isConnected = false;
    _latestAngles = null;
    _isDisposed = false;

    final completer = Completer<void>();

    _socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket']) // Force WebSocket
          .setTimeout(10000)
          .disableAutoConnect()
          .enableForceNew() // Force new connection each time
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      _isConnected = true;
      print('✅ Connected to angle server: $serverUrl');
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      print('❌ Disconnected from server');
    });

    _socket!.onConnectError((error) {
      _isConnected = false;
      print('❌ Connection error: $error');
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    });

    // Wait for connection to be established
    return completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        if (!completer.isCompleted) {
          print('⚠️ Connection timed out');
          // Don't throw, just let it be disconnected
          completer.complete();
        }
      },
    );
  }

  void _setupListeners() {
    if (_socket == null) return;

    _socket!.onAny((event, data) {
      print('🔍 SOCKET EVENT RECEIVED: $event');
    });

    _socket!.on('angles-update', (data) {
      print('📥 RAW SOCKET DATA RECEIVED (Type: ${data.runtimeType}): $data');
      if (_isDisposed) return;
      try {
        final Map<String, dynamic> jsonMap;
        if (data is String) {
          print('⚠️ Warning: Data is String');
          return;
        } else {
          jsonMap = Map<String, dynamic>.from(data as Map);
        }

        final angles = Angles.fromJson(jsonMap);
        _getAngleController().add(angles);
        _latestAngles = angles;
        print('✅ Parsed & Streamed Angles');
      } catch (e) {
        print('❌ Parse error: $e');
      }
    });
  }

  /// Clean up socket without closing stream controller
  void _cleanupSocket() {
    if (_socket != null) {
      _socket!.clearListeners();
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
  }

  /// Disconnect and clean up socket (but keep stream controller alive for reuse)
  void disconnect() {
    _cleanupSocket();
    _isConnected = false;
    _latestAngles = null;
  }

  bool get isConnected => _isConnected;

  /// Get latest angles synchronously (cached, null if none received)
  Angles? get latestAngles => _latestAngles;

  /// Check if any angles have been received
  bool get hasAngles => _latestAngles != null;

  /// Select action - notify backend which measurements to filter and send
  void selectAction(String actionName) {
    if (_socket != null && _isConnected) {
      // Ensure listeners are set up if not already (safeguard)
      if (!_socket!.hasListeners('angles-update')) {
        _setupListeners();
      }

      _socket!.emit('select-action', actionName);
      print('📤 Sent action selection: $actionName');
    } else {
      print('⚠️ Cannot select action - not connected');
    }
  }

  /// Reset the service state (called when navigating away)
  void reset() {
    disconnect();
    _latestAngles = null;
  }

  /// Fully dispose the service (only call on app shutdown)
  void dispose() {
    _isDisposed = true;
    disconnect();
    _angleController?.close();
    _angleController = null;
  }
}
