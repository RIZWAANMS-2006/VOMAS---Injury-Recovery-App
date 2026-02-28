// lib/bloc/user/user_event.dart
// Events for the UserBloc

/// Base class for all user events
abstract class UserEvent {
  const UserEvent();
}

/// Load all users on startup
class LoadUsersRequested extends UserEvent {
  const LoadUsersRequested();
}

/// Add a new user
class AddUserRequested extends UserEvent {
  final String name;
  const AddUserRequested(this.name);
}

/// Delete a user
class DeleteUserRequested extends UserEvent {
  final String userId;
  const DeleteUserRequested(this.userId);
}

/// Select a user to proceed to home screen
class SelectUserRequested extends UserEvent {
  final String userId;
  const SelectUserRequested(this.userId);
}
