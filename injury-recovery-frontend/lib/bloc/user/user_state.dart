// lib/bloc/user/user_state.dart
// State for the UserBloc

import 'package:VOMAS/data/models/user_model.dart';

/// Possible status states for the user screen
enum UserStatus { initial, loading, loaded, error }

/// State class for user management
class UserState {
  /// Current loading/error status
  final UserStatus status;

  /// List of all users
  final List<UserModel> users;

  /// Currently selected user (for navigation)
  final UserModel? selectedUser;

  /// Whether navigation should happen
  final bool shouldNavigate;

  /// Error message
  final String? errorMessage;

  const UserState({
    this.status = UserStatus.initial,
    this.users = const [],
    this.selectedUser,
    this.shouldNavigate = false,
    this.errorMessage,
  });

  UserState copyWith({
    UserStatus? status,
    List<UserModel>? users,
    UserModel? selectedUser,
    bool? shouldNavigate,
    String? errorMessage,
    bool clearSelectedUser = false,
  }) {
    return UserState(
      status: status ?? this.status,
      users: users ?? this.users,
      selectedUser: clearSelectedUser
          ? null
          : (selectedUser ?? this.selectedUser),
      shouldNavigate: shouldNavigate ?? this.shouldNavigate,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get hasUsers => users.isNotEmpty;

  @override
  String toString() =>
      'UserState(status: $status, usersCount: ${users.length}, selected: $selectedUser)';
}
