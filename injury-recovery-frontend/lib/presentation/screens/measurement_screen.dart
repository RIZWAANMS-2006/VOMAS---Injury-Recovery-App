// lib/presentation/screens/measurement_screen.dart
// Screen displaying measurements for the selected action

import 'package:VOMAS/data/services/api_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:VOMAS/bloc/angle_bloc.dart';
import 'package:VOMAS/bloc/angle_event.dart';
import 'package:VOMAS/bloc/angle_state.dart';
import 'package:VOMAS/data/models/action_measurement_mapping.dart';
import 'package:VOMAS/data/models/action_type.dart';
import 'package:VOMAS/data/services/angle_services.dart';
import 'package:VOMAS/presentation/widgets/measurement_card.dart';

/// Screen that displays measurements for a selected action
class MeasurementScreen extends StatelessWidget {
  final ActionType actionType;

  const MeasurementScreen({super.key, required this.actionType});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AngleBloc(AngleService()),
      child: _MeasurementScreenContent(actionType: actionType),
    );
  }
}

/// Content widget that safely accesses context after BlocProvider is ready
class _MeasurementScreenContent extends StatefulWidget {
  final ActionType actionType;

  const _MeasurementScreenContent({required this.actionType});

  @override
  State<_MeasurementScreenContent> createState() =>
      _MeasurementScreenContentState();
}

class _MeasurementScreenContentState extends State<_MeasurementScreenContent> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Wait a frame for the widget tree to be ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final measurement = getMeasurementForAction(widget.actionType);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final gradientColors = widget.actionType.gradientColors;

    // Show loading animation while initializing
    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF121212) : null,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Loading...',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : null,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom App Bar with gradient
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              stretch: true,
              backgroundColor: isDarkMode
                  ? const Color(0xFF1E1E2E)
                  : Colors.white,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background pattern
                      Positioned(
                        right: -50,
                        top: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        left: -30,
                        bottom: -30,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    widget.actionType.icon,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Selected Action',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.actionType.displayName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Connection status
            SliverToBoxAdapter(
              child: _ConnectionStatusBar(
                actionName: widget.actionType.displayName,
              ),
            ),

            // Measurements section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: gradientColors.first.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.analytics_rounded,
                        color: gradientColors.first,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Measurements',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Measurement cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: BlocBuilder<AngleBloc, AngleState>(
                  builder: (context, state) {
                    return MeasurementCardsRow(
                      shoulder: state.latestAngles?.shoulder,
                      elbow: state.latestAngles?.elbow,
                      wrist: state.latestAngles?.wrist,
                    );
                  },
                ),
              ),
            ),

            // Bottom spacing
            const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
          ],
        ),
      ),
    );
  }
}

/// Connection status bar widget
class _ConnectionStatusBar extends StatelessWidget {
  final String actionName;

  const _ConnectionStatusBar({required this.actionName});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return BlocBuilder<AngleBloc, AngleState>(
      builder: (context, state) {
        final isConnected =
            state.connectionStatus == ConnectionStatus.connected;
        final isConnecting =
            state.connectionStatus == ConnectionStatus.connecting;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF2A2A3E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isConnected
                      ? Colors.green
                      : isConnecting
                      ? Colors.orange
                      : Colors.red,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isConnected
                                  ? Colors.green
                                  : isConnecting
                                  ? Colors.orange
                                  : Colors.red)
                              .withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Status text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isConnected
                          ? 'Connected to Sensor'
                          : isConnecting
                          ? 'Connecting...'
                          : 'Sensor Disconnected',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!isConnected && !isConnecting)
                      Text(
                        'Tap Connect to receive live data',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(
                            0.6,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Calibrate button (only show when connected)
              if (isConnected) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<AngleBloc>().add(CalibrateRequested());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Calibration signal sent'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  icon: const Icon(
                    Icons.tune_rounded,
                    size: 20,
                  ),
                  label: const Text('Calibrate'),
                ),
                const SizedBox(width: 8),
              ],
              // Connect/Disconnect button
              ElevatedButton.icon(
                onPressed: () {
                  if (isConnected) {
                    context.read<AngleBloc>().add(DisconnectRequested());
                  } else if (!isConnecting) {
                    // Connect and register action with backend
                    context.read<AngleBloc>().add(
                      ConnectRequested(
                        ApiConfig.baseUrl,
                        actionName: actionName,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isConnected
                      ? Colors.red.shade400
                      : const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                icon: Icon(
                  isConnected ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  size: 20,
                ),
                label: Text(
                  isConnected
                      ? 'Stop'
                      : isConnecting
                      ? 'Wait...'
                      : 'Connect',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
