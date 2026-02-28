// lib/presentation/screens/user_selection_screen.dart
// Entry point screen for selecting, adding, or deleting user profiles

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:VOMAS/bloc/user/user_bloc.dart';
import 'package:VOMAS/bloc/user/user_event.dart';
import 'package:VOMAS/bloc/user/user_state.dart';
import 'package:VOMAS/data/models/user_model.dart';
import 'package:VOMAS/data/services/excel_export_service.dart';
import 'package:VOMAS/presentation/screens/home_screen.dart';

/// Screen for selecting a user profile or creating/deleting users
class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserBloc()..add(const LoadUsersRequested()),
      child: const _UserSelectionContent(),
    );
  }
}

class _UserSelectionContent extends StatelessWidget {
  const _UserSelectionContent();

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listenWhen: (previous, current) =>
          current.shouldNavigate && current.selectedUser != null,
      listener: (context, state) {
        if (state.shouldNavigate && state.selectedUser != null) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return HomeScreen(
                  userId: state.selectedUser!.id,
                  userName: state.selectedUser!.name,
                );
              },
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0, 0.05),
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
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              // Users grid
              Expanded(child: _buildUsersGrid()),
            ],
          ),
        ),
        floatingActionButton: _buildAddUserFAB(context),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF4A90E2), const Color(0xFF50E3C2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.people_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VOMAS',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select your profile to continue',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Export All button
              BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (!state.hasUsers) return const SizedBox.shrink();
                  return IconButton(
                    icon: const Icon(
                      Icons.file_download_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                    tooltip: 'Export All History',
                    onPressed: () => _exportAllHistory(context),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersGrid() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state.status == UserStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!state.hasUsers) {
          return _buildEmptyState(context);
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: state.users.length,
          itemBuilder: (context, index) {
            return _UserCard(user: state.users[index], colorIndex: index);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_add_rounded,
                size: 48,
                color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Users Yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to create your first profile',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddUserFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddUserDialog(context),
      backgroundColor: const Color(0xFF4A90E2),
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.person_add_rounded),
      label: const Text(
        'Add User',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final controller = TextEditingController();
    final bloc = context.read<UserBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(Icons.person_add_rounded, color: Color(0xFF4A90E2)),
              SizedBox(width: 12),
              Text('New User'),
            ],
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Enter name',
              prefixIcon: const Icon(Icons.person_outline_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                bloc.add(AddUserRequested(value.trim()));
                Navigator.pop(dialogContext);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  bloc.add(AddUserRequested(name));
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _exportAllHistory(BuildContext context) async {
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
            Text('Exporting all users history...'),
          ],
        ),
        duration: Duration(seconds: 3),
      ),
    );

    try {
      final exportService = ExcelExportService();
      final filePath = await exportService.exportAllUsersHistory();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Exported: ${filePath.split('/').last}'),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () => ExcelExportService.openFile(filePath),
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
}

/// Individual user profile card
class _UserCard extends StatelessWidget {
  final UserModel user;
  final int colorIndex;

  const _UserCard({required this.user, required this.colorIndex});

  /// Avatar gradient colors palette
  static const List<List<Color>> _avatarColors = [
    [Color(0xFF4A90E2), Color(0xFF357ABD)],
    [Color(0xFF50E3C2), Color(0xFF3DBEA6)],
    [Color(0xFFF5A623), Color(0xFFD4891A)],
    [Color(0xFF9B59B6), Color(0xFF7D3C98)],
    [Color(0xFFE74C3C), Color(0xFFC0392B)],
    [Color(0xFF1ABC9C), Color(0xFF16A085)],
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = _avatarColors[colorIndex % _avatarColors.length];

    return GestureDetector(
      onTap: () {
        context.read<UserBloc>().add(SelectUserRequested(user.id));
      },
      onLongPress: () => _showDeleteDialog(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2A2A3E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(isDarkMode ? 0.2 : 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors[0].withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  user.initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                user.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            // Subtitle hint
            Text(
              'Tap to continue',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final bloc = context.read<UserBloc>();

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
              Text('Delete User?'),
            ],
          ),
          content: Text(
            'Delete "${user.name}" and all their activity history? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                bloc.add(DeleteUserRequested(user.id));
                Navigator.pop(dialogContext);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
