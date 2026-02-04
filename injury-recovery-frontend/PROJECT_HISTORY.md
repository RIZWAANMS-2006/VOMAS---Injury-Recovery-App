# VOMAS - Project History & Documentation

> **Purpose**: This document provides a comprehensive history of the project for future developers or AI assistants to understand what has been built and how the codebase is structured.

---

## Project Overview

**App Name**: VOMAS  
**Platform**: Flutter (Windows, Android)  
**State Management**: BLoC (flutter_bloc)  
**Storage**: SharedPreferences  
**Sensor Integration**: Socket.IO for real-time angle data

---

## Session Summary (February 2026)

### Goal
Redesign the Flutter VOMAS with a modern UI featuring:
- Home screen with activity history and 6 selectable action cards
- Measurement screen displaying Shoulder/Elbow/Wrist values
- Persistent activity logging
- Dark mode support

---

## Architecture

```
lib/
├── main.dart                          # App entry point
├── bloc/
│   ├── angle_bloc.dart                # Sensor data state management
│   ├── angle_event.dart
│   ├── angle_state.dart
│   └── home/
│       ├── home_bloc.dart             # Home screen state (NEW)
│       ├── home_event.dart            # (NEW)
│       └── home_state.dart            # (NEW)
├── core/
│   └── theme/
│       ├── app_colors.dart            # Color palette (MODIFIED)
│       └── app_theme.dart             # Light/Dark themes (MODIFIED)
├── data/
│   ├── models/
│   │   ├── action_type.dart           # 6 action types enum (NEW)
│   │   ├── action_measurement_mapping.dart  # Action→Measurement map (NEW)
│   │   ├── activity_history_item.dart # History model (NEW)
│   │   ├── angles.dart                # Sensor angles model
│   │   └── vomas_task.dart            # VOMAS task model
│   └── services/
│       ├── activity_history_service.dart  # SharedPreferences storage (NEW)
│       └── angle_services.dart        # Socket.IO service
└── presentation/
    ├── screens/
    │   ├── home_screen.dart           # Main home screen (NEW)
    │   └── measurement_screen.dart    # Measurement display (NEW)
    └── widgets/
        ├── action_card.dart           # Action card + grid (NEW)
        ├── activity_history_card.dart # History card + empty state (NEW)
        └── measurement_card.dart      # Measurement display cards (NEW)
```

---

## Features Implemented

### 1. Home Screen (`home_screen.dart`)
- **SliverAppBar** with title "VOMAS"
- **Actions Grid**: 6 tappable action cards in 2x3 layout
- **Activity History Section**: Scrollable list at bottom
- **Clear History**: Button in app bar when history exists
- **Navigation**: Tap action → Navigate to MeasurementScreen with fade/slide transition

### 2. Action Cards (`action_card.dart`)
- Gradient backgrounds per action type
- Icons and descriptions
- Press animation (scale effect)
- Grid layout with responsive sizing

### 3. Measurement Screen (`measurement_screen.dart`)
- **Gradient header** with action icon and name
- **Connection status bar** for sensor
- **3 measurement cards**: Shoulder, Elbow, Wrist
- **Loading animation** during navigation
- **Connect/Disconnect** button for sensor

### 4. Activity History (`activity_history_card.dart`)
- Card-based list with swipe-to-delete
- Displays action name, measurements, timestamp
- **EmptyHistoryWidget** when no history (centered)
- Uses **Wrap** for measurements to prevent overflow

### 5. Action → Measurement Mapping (`action_measurement_mapping.dart`)

| Action | Shoulder | Elbow | Wrist |
|--------|----------|-------|-------|
| Flexion / Extension | Roll | Roll | Pitch |
| Abduction | Roll | Roll | Pitch |
| Internal / External Rotation | Pitch | Roll | Pitch |
| Horizontal Abduction / Adduction | Yaw | Roll | Pitch |
| Forearm Pronation / Supination | Roll | Roll | Roll |
| Radial / Ulnar Deviation | Roll | Roll | Yaw |

### 6. Themes (`app_theme.dart`, `app_colors.dart`)
- **Light theme**: Off-white background, white cards
- **Dark theme**: Dark background (#121212), dark cards (#2A2A3E)
- **System theme detection**: Auto-switches based on device setting
- **Extended colors**: Gradients for each action type

---

## Key Design Decisions

1. **BLoC Pattern**: Used for both home screen (HomeBloc) and sensor data (AngleBloc)
2. **StatefulWidget for MeasurementScreen content**: Prevents red error screen flash during navigation by showing loading animation first
3. **Wrap instead of Row**: For measurement badges to prevent overflow
4. **Center widget for EmptyHistoryWidget**: Ensures proper centering
5. **SharedPreferences**: Simple local storage for activity history (max 50 items)

---

## Bug Fixes Applied

| Issue | Solution |
|-------|----------|
| "No Activity" text not centered | Wrapped in `Center` with `crossAxisAlignment.center` |
| History card overflow | Changed `Row` to `Wrap` for measurement badges |
| Red screen flash on navigation | Added loading animation with `addPostFrameCallback` |
| Undefined `actionType` in StatefulWidget | Changed to `widget.actionType` |

---

## Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.3
  google_fonts: ^6.1.0
  shared_preferences: ^2.2.2
  socket_io_client: ^2.0.3+1
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
```

---

## Layout Structure (Home Screen)

```
CustomScrollView
├── SliverAppBar (title + clear history button)
├── SliverToBoxAdapter (Actions Section Header)
├── SliverToBoxAdapter (ActionsGrid - 6 cards)
├── SliverToBoxAdapter (History Section)
└── SliverPadding (bottom: 24)
```

---

## How to Run

```powershell
cd "c:\Coding\Dart (Flutter)\VOMASapp\VOMAS-frontend"
flutter pub get
flutter run -d windows   # For Windows
flutter run -d android   # For Android
flutter build apk        # Build APK
```

---

## Files Modified from Original

| File | Changes |
|------|---------|
| `main.dart` | Changed home to `HomeScreen`, added themes |
| `app_colors.dart` | Added dark mode colors, gradients |
| `app_theme.dart` | Added complete dark theme |
| `pubspec.yaml` | Added `shared_preferences` |
| `widget_test.dart` | Updated to match new home screen |

---

## Future Considerations

1. **Sensor URL**: Currently hardcoded as `http://10.81.251.94:3000` - should be configurable
2. **VomasTestScreen**: Still exists, accessible if needed but not in main navigation
3. **History limit**: Set to 50 items max - adjustable in `ActivityHistoryService`

---

*Last Updated: February 1, 2026*
