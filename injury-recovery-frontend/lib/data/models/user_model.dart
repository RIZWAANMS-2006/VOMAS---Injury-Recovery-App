// lib/data/models/user_model.dart
// Model representing a user profile in VOMAS

import 'dart:convert';

/// Represents a user profile
class UserModel {
  /// Unique identifier for this user
  final String id;

  /// User's display name
  final String name;

  /// When this user was created
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  /// Create a new user with auto-generated ID
  factory UserModel.create(String name) {
    return UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
    );
  }

  /// Create from JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'createdAt': createdAt.toIso8601String()};
  }

  /// Get the initial letter for avatar display
  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  @override
  String toString() => 'UserModel(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Helper to encode list of UserModel to JSON string
String encodeUserList(List<UserModel> users) {
  return jsonEncode(users.map((e) => e.toJson()).toList());
}

/// Helper to decode JSON string to list of UserModel
List<UserModel> decodeUserList(String jsonString) {
  if (jsonString.isEmpty) return [];
  final List<dynamic> jsonList = jsonDecode(jsonString);
  return jsonList
      .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
      .toList();
}
