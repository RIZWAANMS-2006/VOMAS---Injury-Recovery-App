// lib/main.dart
// Main entry point for the VOMAS

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:VOMAS/core/theme/app_theme.dart';
import 'package:VOMAS/presentation/screens/user_selection_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const VOMASApp());
}

/// Root widget for the VOMAS
class VOMASApp extends StatelessWidget {
  const VOMASApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VOMAS',
      debugShowCheckedModeBanner: false,

      // Themes
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode:
          ThemeMode.system, // Automatically switch based on device setting
      // Home screen
      home: const UserSelectionScreen(),

      // Custom page transitions
      builder: (context, child) {
        return MediaQuery(
          // Prevent text scaling from breaking layout
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
