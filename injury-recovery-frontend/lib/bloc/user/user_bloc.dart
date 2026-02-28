// lib/bloc/user/user_bloc.dart
// BLoC for user management - handles CRUD and selection

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:VOMAS/data/services/user_service.dart';

import 'user_event.dart';
import 'user_state.dart';

/// BLoC for managing user profiles
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserService _userService;

  UserBloc({UserService? userService})
    : _userService = userService ?? UserService(),
      super(const UserState()) {
    on<LoadUsersRequested>(_onLoadUsers);
    on<AddUserRequested>(_onAddUser);
    on<DeleteUserRequested>(_onDeleteUser);
    on<SelectUserRequested>(_onSelectUser);
  }

  Future<void> _onLoadUsers(
    LoadUsersRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserStatus.loading));
    try {
      await _userService.init();
      final users = await _userService.getUsers();
      emit(state.copyWith(status: UserStatus.loaded, users: users));
    } catch (e) {
      emit(
        state.copyWith(
          status: UserStatus.error,
          errorMessage: 'Failed to load users: $e',
        ),
      );
    }
  }

  Future<void> _onAddUser(
    AddUserRequested event,
    Emitter<UserState> emit,
  ) async {
    try {
      final newUser = await _userService.addUser(event.name);
      final updatedUsers = [...state.users, newUser];
      emit(state.copyWith(users: updatedUsers));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to add user: $e'));
    }
  }

  Future<void> _onDeleteUser(
    DeleteUserRequested event,
    Emitter<UserState> emit,
  ) async {
    try {
      await _userService.deleteUser(event.userId);
      final updatedUsers = state.users
          .where((u) => u.id != event.userId)
          .toList();
      emit(state.copyWith(users: updatedUsers));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete user: $e'));
    }
  }

  Future<void> _onSelectUser(
    SelectUserRequested event,
    Emitter<UserState> emit,
  ) async {
    try {
      await _userService.setActiveUser(event.userId);
      final user = state.users.firstWhere((u) => u.id == event.userId);
      emit(state.copyWith(selectedUser: user, shouldNavigate: true));
      // Reset navigation flag
      emit(state.copyWith(shouldNavigate: false));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to select user: $e'));
    }
  }
}
