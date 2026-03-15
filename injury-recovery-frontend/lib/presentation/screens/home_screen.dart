// lib/presentation/screens/home_screen.dart
// Modern home screen with activity history and action selection

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:VOMAS/bloc/home/home_bloc.dart';
import 'package:VOMAS/bloc/home/home_event.dart';
import 'package:VOMAS/bloc/home/home_state.dart';
import 'package:VOMAS/bloc/angle_bloc.dart';
import 'package:VOMAS/bloc/angle_event.dart';
import 'package:VOMAS/bloc/angle_state.dart';
import 'package:VOMAS/data/models/action_type.dart';
import 'package:VOMAS/data/services/excel_export_service.dart';
import 'package:VOMAS/data/services/angle_services.dart';
import 'package:VOMAS/data/services/api_config.dart';
import 'package:VOMAS/presentation/widgets/activity_history_card.dart';
import 'package:VOMAS/presentation/widgets/single_measurement_card.dart';

/// The main home screen of the app
class HomeScreen extends StatelessWidget {
  final String userId;
  final String userName;

  const HomeScreen({super.key, required this.userId, required this.userName});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
          create: (_) =>
              HomeBloc(userId: userId)..add(const LoadHistoryRequested()),
        ),
      ],
      // We need to access HomeBloc's historyService for AngleBloc
      child: Builder(
        builder: (context) {
          final homeBloc = context.read<HomeBloc>();
          return BlocProvider<AngleBloc>(
            create: (_) => AngleBloc(AngleService(), homeBloc.historyService),
            child: _HomeScreenContent(userName: userName),
          );
        }
      ),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  final String userName;

  const _HomeScreenContent({required this.userName});

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  // We'll keep track of a generic "Session" for recording since
  // there's no specific action selected before connecting.
  final ActionType _sessionActionType = ActionType.flexionExtension;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            _buildAppBar(context),
            
            // Actions + Measurements List
            _buildMeasurementsList(),

            // Activity History Section (at bottom)
            _buildHistorySection(),

            // Bottom padding
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      floating: true,
      snap: true,
      expandedHeight: 80,
      backgroundColor: theme.scaffoldBackgroundColor,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VOMAS',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          Text(
            widget.userName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF4A90E2),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        BlocBuilder<AngleBloc, AngleState>(
          builder: (context, state) {
            final isConnected = state.connectionStatus == ConnectionStatus.connected;
            final isConnecting = state.connectionStatus == ConnectionStatus.connecting;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isConnected)
                  TextButton.icon(
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
                    icon: const Icon(Icons.tune_rounded, size: 18),
                    label: const Text('Calibrate'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF9C27B0),
                    ),
                  ),
                const SizedBox(width: 4),
                ElevatedButton.icon(
                  onPressed: () {
                    if (isConnected) {
                       context.read<AngleBloc>().add(DisconnectRequested());
                       // Refresh history to show recent session
                       context.read<HomeBloc>().add(const RefreshHistoryRequested());
                    } else if (!isConnecting) {
                       context.read<AngleBloc>().add(
                         ConnectRequested(
                           ApiConfig.baseUrl,
                           actionName: 'All Measure',
                           actionType: _sessionActionType,
                           customHistoryName: 'all measurement',
                         ),
                       );
                    }
                  },
                  icon: Icon(
                    isConnected ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    size: 18,
                  ),
                  label: Text(
                    isConnected ? 'Stop' : isConnecting ? 'Wait...' : 'Connect',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isConnected
                        ? Colors.red.shade400
                        : const Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(0, 36),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            );
          },
        ),
        BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.hasHistory)
                  IconButton(
                    icon: const Icon(Icons.history_rounded),
                    tooltip: 'History',
                    onPressed: () {
                       // Optional: Scroll to bottom or show bottom sheet
                       // Currently just an indicator 
                    },
                  ),
                if (state.hasHistory)
                  IconButton(
                    icon: const Icon(Icons.file_download_outlined),
                    tooltip: 'Export to Excel',
                    onPressed: () => _exportHistory(context, state),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMeasurementsList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final actionType = ActionType.values[index];
            final theme = Theme.of(context);
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Action Header
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: actionType.gradientColors.first.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          actionType.icon,
                          size: 16,
                          color: actionType.gradientColors.first,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        actionType.displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Single unified measurement card 
                BlocBuilder<AngleBloc, AngleState>(
                  builder: (context, state) {
                    final isConnected = state.connectionStatus == ConnectionStatus.connected;
                    final anglesForAction =
                        state.getAnglesForAction(actionType.displayName);
                    return SingleMeasurementCard(
                      shoulder: anglesForAction?.shoulder,
                      elbow: anglesForAction?.elbow,
                      wrist: anglesForAction?.wrist,
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            );
          },
          childCount: ActionType.values.length,
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return SliverToBoxAdapter(
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final theme = Theme.of(context);
          final isDarkMode = theme.brightness == Brightness.dark;

          return Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E2E) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A90E2).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.history_rounded,
                          color: Color(0xFF4A90E2),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Activity History',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (state.hasHistory)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF50E3C2).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${state.historyCount} activities',
                            style: const TextStyle(
                              color: Color(0xFF50E3C2),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // History content
                if (state.status == HomeStatus.loading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (!state.hasHistory)
                  const EmptyHistoryWidget()
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: state.history.length > 5
                          ? 5
                          : state.history.length, // Show max 5 recent
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = state.history[index];
                        return ActivityHistoryCard(
                          item: item,
                          onDelete: () {
                            context.read<HomeBloc>().add(
                              RemoveHistoryItem(item.id),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _exportHistory(BuildContext context, HomeState state) async {
    if (!state.hasHistory) return;

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text('Generating Excel file...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      final exportService = ExcelExportService();
      final filePath = await exportService.exportHistory(
        state.history,
        widget.userName,
      );

      if (!context.mounted) return;

      // Clear the loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show success with open option
      final fileName = filePath.split('/').last;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Exported: $fileName'),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () {
              ExcelExportService.openFile(filePath);
            },
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 12),
              Text('Clear History?'),
            ],
          ),
          content: const Text(
            'This will permanently delete all your activity history. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                context.read<HomeBloc>().add(const ClearHistoryRequested());
                Navigator.pop(dialogContext);
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }
}
