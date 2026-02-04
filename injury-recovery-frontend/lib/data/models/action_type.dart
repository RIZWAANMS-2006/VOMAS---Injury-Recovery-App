// lib/data/models/action_type.dart
// Defines the 6 action types for VOMAS exercises

import 'package:flutter/material.dart';

/// Enum representing the 6 selectable action types
enum ActionType {
  flexionExtension,
  abduction,
  internalExternalRotation,
  horizontalAbductionAdduction,
  forearmPronationSupination,
  radialUlnarDeviation,
}

/// Extension to provide display names and icons for each action type
extension ActionTypeExtension on ActionType {
  /// Human-readable display name for the action
  String get displayName {
    switch (this) {
      case ActionType.flexionExtension:
        return 'Flexion / Extension';
      case ActionType.abduction:
        return 'Abduction';
      case ActionType.internalExternalRotation:
        return 'Internal / External Rotation';
      case ActionType.horizontalAbductionAdduction:
        return 'Horizontal Abduction / Adduction';
      case ActionType.forearmPronationSupination:
        return 'Forearm Pronation / Supination';
      case ActionType.radialUlnarDeviation:
        return 'Radial / Ulnar Deviation';
    }
  }

  /// Short description for the action
  String get description {
    switch (this) {
      case ActionType.flexionExtension:
        return 'Bending and straightening movements';
      case ActionType.abduction:
        return 'Movement away from body midline';
      case ActionType.internalExternalRotation:
        return 'Rotating inward and outward';
      case ActionType.horizontalAbductionAdduction:
        return 'Horizontal arm movements';
      case ActionType.forearmPronationSupination:
        return 'Palm down and palm up rotation';
      case ActionType.radialUlnarDeviation:
        return 'Wrist side-to-side movements';
    }
  }

  /// Icon representing the action type
  IconData get icon {
    switch (this) {
      case ActionType.flexionExtension:
        return Icons.swap_vert_rounded;
      case ActionType.abduction:
        return Icons.open_with_rounded;
      case ActionType.internalExternalRotation:
        return Icons.rotate_right_rounded;
      case ActionType.horizontalAbductionAdduction:
        return Icons.swap_horiz_rounded;
      case ActionType.forearmPronationSupination:
        return Icons.sync_rounded;
      case ActionType.radialUlnarDeviation:
        return Icons.compare_arrows_rounded;
    }
  }

  /// Gradient colors for the action card
  List<Color> get gradientColors {
    switch (this) {
      case ActionType.flexionExtension:
        return [const Color(0xFF4A90E2), const Color(0xFF357ABD)];
      case ActionType.abduction:
        return [const Color(0xFF50E3C2), const Color(0xFF3DBEA6)];
      case ActionType.internalExternalRotation:
        return [const Color(0xFFF5A623), const Color(0xFFD4891A)];
      case ActionType.horizontalAbductionAdduction:
        return [const Color(0xFFE74C3C), const Color(0xFFC0392B)];
      case ActionType.forearmPronationSupination:
        return [const Color(0xFF9B59B6), const Color(0xFF7D3C98)];
      case ActionType.radialUlnarDeviation:
        return [const Color(0xFF1ABC9C), const Color(0xFF16A085)];
    }
  }

  /// Converts enum to storage-friendly string key
  String get storageKey => name;

  /// Creates ActionType from storage key
  static ActionType fromStorageKey(String key) {
    return ActionType.values.firstWhere(
      (e) => e.name == key,
      orElse: () => ActionType.flexionExtension,
    );
  }

  /// Creates ActionType from display name (from backend API)
  static ActionType fromDisplayName(String displayName) {
    return ActionType.values.firstWhere(
      (e) => e.displayName == displayName,
      orElse: () => ActionType.flexionExtension,
    );
  }
}
