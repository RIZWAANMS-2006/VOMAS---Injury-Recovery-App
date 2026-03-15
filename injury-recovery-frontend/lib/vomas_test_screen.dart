// _AngleChip widget (same as previous response)
// ignore_for_file: deprecated_member_use

import 'package:VOMAS/data/services/api_config.dart';
import 'package:flutter/material.dart';
import 'package:VOMAS/data/models/angles.dart';
import 'package:VOMAS/data/models/vomas_task.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:VOMAS/bloc/angle_bloc.dart';
import 'package:VOMAS/bloc/angle_event.dart';
import 'package:VOMAS/bloc/angle_state.dart';
import 'package:VOMAS/data/models/vomas_tasks.dart'; // Your predefined tasks
import 'package:VOMAS/data/services/angle_services.dart';
import 'package:VOMAS/data/services/activity_history_service.dart';

class VomasTestScreen extends StatelessWidget {
  const VomasTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AngleBloc(AngleService(), ActivityHistoryService()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('VOMAS Task Validator'),
          actions: [
            BlocBuilder<AngleBloc, AngleState>(
              builder: (context, state) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Connection Status
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getConnectionColor(state.connectionStatus),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getConnectionIcon(state.connectionStatus),
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            _getConnectionText(state.connectionStatus),
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    // Connect/Disconnect Button
                    IconButton(
                      icon: Icon(
                        state.connectionStatus == ConnectionStatus.connected
                            ? Icons.stop
                            : Icons.play_arrow,
                      ),
                      onPressed: () {
                        if (state.connectionStatus ==
                            ConnectionStatus.connected) {
                          context.read<AngleBloc>().add(DisconnectRequested());
                        } else {
                          context.read<AngleBloc>().add(
                            ConnectRequested(ApiConfig.baseUrl),
                          );
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<AngleBloc, AngleState>(
          builder: (context, state) {
            final latestAngles = state.latestAngles?.values.first;
            if (latestAngles != null) {
              print(
                '🎨 UI: Rebuilding with new angles. Shoulder: ${latestAngles.shoulder.angle}',
              );
            }
            return Column(
              children: [
                // Task Selection
                _TaskSelector(state: state),

                // Status Indicator
                _StatusIndicator(state: state),

                // Current Angles
                if (latestAngles != null)
                  _CurrentAngles(state: state, latestAngles: latestAngles),

                // Real-time Graph
                Expanded(
                  child: _AngleGraph(state: state, latestAngles: latestAngles),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Color _getConnectionColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.connecting:
        return Colors.orange;
      case ConnectionStatus.error:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getConnectionIcon(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Icons.wifi;
      case ConnectionStatus.connecting:
        return Icons.wifi_1_bar;
      case ConnectionStatus.error:
        return Icons.wifi_off;
      default:
        return Icons.wifi_off;
    }
  }

  String _getConnectionText(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return 'Live';
      case ConnectionStatus.connecting:
        return 'Connecting';
      case ConnectionStatus.error:
        return 'Error';
      case ConnectionStatus.disconnected:
        return 'Offline';
      default:
        return 'Initial';
    }
  }
}

class _TaskSelector extends StatelessWidget {
  final AngleState state;

  const _TaskSelector({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: DropdownButtonFormField<VomasTask>(
        decoration: InputDecoration(
          labelText: 'Select VOMAS Task',
          border: OutlineInputBorder(),
        ),
        items: predefinedVomasTasks.map((task) {
          return DropdownMenuItem(value: task, child: Text(task.name));
        }).toList(),
        value: state.selectedTask,
        onChanged: (task) {
          if (task != null) {
            context.read<AngleBloc>().add(TaskSelected(task));
          }
        },
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final AngleState state;

  const _StatusIndicator({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: state.isCorrect
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: state.isCorrect ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            transform: Matrix4.identity()..scale(state.isCorrect ? 1.1 : 1.0),
            child: Icon(
              state.isCorrect ? Icons.check_circle : Icons.hourglass_empty,
              size: 48,
              color: state.isCorrect ? Colors.green : Colors.orange,
            ),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.selectedTask?.name ?? 'No Task Selected',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                state.isCorrect
                    ? '✅ CORRECT POSITION!'
                    : state.latestAngles != null
                    ? '🔄 Checking position...'
                    : '📡 Waiting for angles...',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: state.isCorrect
                      ? Colors.green[700]
                      : Colors.orange[700],
                ),
              ),
              if (state.timestamp != null)
                Text(
                  'Updated: ${state.timestamp!.toString().substring(11, 19)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrentAngles extends StatelessWidget {
  final AngleState state;
  final Angles latestAngles;

  const _CurrentAngles({required this.state, required this.latestAngles});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text('Current Angles', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AngleChip(
                'Shoulder',
                latestAngles.shoulder.angle,
                state.selectedTask?.shoulder,
              ),
              _AngleChip(
                'Elbow',
                latestAngles.elbow.angle,
                state.selectedTask?.elbow,
              ),
              _AngleChip(
                'Wrist',
                latestAngles.wrist.angle,
                state.selectedTask?.wrist,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AngleGraph extends StatelessWidget {
  final AngleState state;
  final Angles? latestAngles;

  const _AngleGraph({required this.state, required this.latestAngles});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Real-time Angle Graph',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              painter: AngleGraphPainter(latestAngles),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }
}

class _AngleChip extends StatelessWidget {
  final String label;
  final double value;
  final AngleRange? targetRange;

  const _AngleChip(this.label, this.value, this.targetRange);

  bool get isInRange =>
      targetRange == null ||
      (value >= targetRange!.min && value <= targetRange!.max);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isInRange
                ? Colors.green.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isInRange ? Colors.green : Colors.red,
              width: 1.5,
            ),
          ),
          child: Text(
            '${value.toStringAsFixed(1)}°',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isInRange ? Colors.green[700] : Colors.red[700],
              fontSize: 18,
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        if (targetRange != null)
          Text(
            '${targetRange!.min}-${targetRange!.max}°',
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          ),
      ],
    );
  }
}

// Simplified graph painter (shows latest angles as points)
class AngleGraphPainter extends CustomPainter {
  final Angles? latestAngles;

  AngleGraphPainter(this.latestAngles);

  @override
  void paint(Canvas canvas, Size size) {
    if (latestAngles == null) return;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = (size.width / 2 - 40).clamp(50.0, 120.0);

    // Draw shoulder point
    final shoulderAngle = latestAngles!.shoulder.angle;
    final shoulderX = centerX + radius * 0.6 * (shoulderAngle / 180 - 0.5);
    final shoulderY = centerY - radius * 0.6 * (shoulderAngle / 180);

    canvas.drawCircle(
      Offset(shoulderX, shoulderY),
      12,
      Paint()..color = Colors.blue.withOpacity(0.7),
    );

    // Draw elbow point
    final elbowAngle = latestAngles!.elbow.angle;
    final elbowX = centerX + radius * 0.4 * (elbowAngle / 180 - 0.5);
    final elbowY = centerY - radius * 0.4 * (elbowAngle / 180);

    canvas.drawCircle(
      Offset(elbowX, elbowY),
      12,
      Paint()..color = Colors.orange.withOpacity(0.7),
    );

    // Draw wrist point
    final wristAngle = latestAngles!.wrist.angle;
    final wristX = centerX + radius * 0.2 * (wristAngle / 180 - 0.5);
    final wristY = centerY - radius * 0.2 * (wristAngle / 180);

    canvas.drawCircle(
      Offset(wristX, wristY),
      12,
      Paint()..color = Colors.green.withOpacity(0.7),
    );

    // Legend
    final legendTextPainter = TextPainter(
      text: TextSpan(
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
        children: [
          TextSpan(
            text:
                '🔵 Shoulder: ${latestAngles!.shoulder.angle.toStringAsFixed(1)}°\n',
          ),
          TextSpan(
            text:
                '🟠 Elbow: ${latestAngles!.elbow.angle.toStringAsFixed(1)}°\n',
          ),
          TextSpan(
            text: '🟢 Wrist: ${latestAngles!.wrist.angle.toStringAsFixed(1)}°',
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
      maxLines: 3,
    );
    legendTextPainter.layout();
    legendTextPainter.paint(canvas, Offset(20, 20));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
