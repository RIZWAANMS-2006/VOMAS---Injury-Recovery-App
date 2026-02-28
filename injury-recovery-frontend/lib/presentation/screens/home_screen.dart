// lib/presentation/screens/home_screen.dart
// Modern home screen with activity history and action selection

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:VOMAS/bloc/home/home_bloc.dart';
import 'package:VOMAS/bloc/home/home_event.dart';
import 'package:VOMAS/bloc/home/home_state.dart';
import 'package:VOMAS/data/services/excel_export_service.dart';
import 'package:VOMAS/presentation/screens/measurement_screen.dart';
import 'package:VOMAS/presentation/widgets/action_card.dart';
import 'package:VOMAS/presentation/widgets/activity_history_card.dart';

/// The main home screen of the app
class HomeScreen extends StatelessWidget {
  final String userId;
  final String userName;

  const HomeScreen({super.key, required this.userId, required this.userName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          HomeBloc(userId: userId)..add(const LoadHistoryRequested()),
      child: _HomeScreenContent(userName: userName),
    );
  }
}

class _HomeScreenContent extends StatelessWidget {
  final String userName;

  const _HomeScreenContent({required this.userName});

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (previous, current) =>
          current.shouldNavigate && current.selectedAction != null,
      listener: (context, state) {
        if (state.shouldNavigate && state.selectedAction != null) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return MeasurementScreen(actionType: state.selectedAction!);
              },
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0.1, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: child,
                      ),
                    );
                  },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          ).then((_) {
            // Refresh history when returning
            context.read<HomeBloc>().add(const RefreshHistoryRequested());
          });
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              _buildAppBar(context),
              // Actions Section Header
              _buildActionsSectionHeader(),
              // Actions Grid
              _buildActionsGrid(),
              // Activity History Section (at bottom)
              _buildHistorySection(),
              // Bottom padding
              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      floating: true,
      snap: true,
      expandedHeight: 100,
      backgroundColor: theme.scaffoldBackgroundColor,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Switch User',
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
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
              userName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF4A90E2),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      actions: [
        BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Export button
                if (state.hasHistory)
                  IconButton(
                    icon: const Icon(Icons.file_download_outlined),
                    tooltip: 'Export to Excel',
                    onPressed: () => _exportHistory(context, state),
                  ),
                // Clear history button
                if (state.hasHistory)
                  IconButton(
                    icon: const Icon(Icons.delete_sweep_rounded),
                    tooltip: 'Clear History',
                    onPressed: () => _showClearHistoryDialog(context),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 8),
      ],
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

  Widget _buildActionsSectionHeader() {
    return SliverToBoxAdapter(
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5A623).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.touch_app_rounded,
                    color: Color(0xFFF5A623),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Select Action',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionsGrid() {
    return SliverToBoxAdapter(
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return ActionsGrid(
            onActionSelected: (action) {
              context.read<HomeBloc>().add(ActionSelected(action));
            },
            selectedAction: state.selectedAction,
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
        userName,
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
