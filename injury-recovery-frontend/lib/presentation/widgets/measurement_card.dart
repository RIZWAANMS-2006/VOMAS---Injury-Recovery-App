// lib/presentation/widgets/measurement_card.dart
// Card widget for displaying joint measurements on the measurement screen

import 'package:flutter/material.dart';
import 'package:VOMAS/data/models/angles.dart';

/// A large card for displaying a single joint measurement
class MeasurementCard extends StatelessWidget {
  final String jointName;
  final String measurementType;
  final double? liveValue;
  final double? liveSpeed;
  final Color accentColor;
  final IconData icon;
  final int animationDelay;

  const MeasurementCard({
    super.key,
    required this.jointName,
    required this.measurementType,
    this.liveValue,
    this.liveSpeed,
    required this.accentColor,
    required this.icon,
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + animationDelay),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2A2A3E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Icon container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor, accentColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                // Joint name & measurement type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jointName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          measurementType,
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Live value (if connected)
            if (liveValue != null) ...[
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: liveValue!),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, _) {
                    return Column(
                      children: [
                        // Angle value
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                            children: [
                              TextSpan(text: value.toStringAsFixed(1)),
                              TextSpan(
                                text: '°',
                                style: TextStyle(
                                  fontSize: 28,
                                  color: accentColor.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Speed value
                        if (liveSpeed != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.speed_rounded,
                                  size: 18,
                                  color: accentColor.withOpacity(0.8),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${liveSpeed!.toStringAsFixed(1)} m/s',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ] else ...[
              // Waiting for data
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.sensors_rounded,
                      size: 32,
                      color: isDarkMode
                          ? Colors.grey.shade600
                          : Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Awaiting sensor data...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDarkMode
                            ? Colors.grey.shade500
                            : Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Row of three measurement cards for shoulder, elbow, wrist
class MeasurementCardsRow extends StatelessWidget {
  final JointMeasurement? shoulder;
  final JointMeasurement? elbow;
  final JointMeasurement? wrist;

  const MeasurementCardsRow({super.key, this.shoulder, this.elbow, this.wrist});

  /// Capitalize first letter of measurement type for display
  String _formatType(String type) {
    if (type.isEmpty) return type;
    return type[0].toUpperCase() + type.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MeasurementCard(
          jointName: 'Shoulder',
          measurementType: shoulder != null
              ? _formatType(shoulder!.type)
              : 'Waiting...',
          liveValue: shoulder?.angle,
          liveSpeed: shoulder?.speed,
          accentColor: const Color(0xFF4A90E2),
          icon: Icons.accessibility_new_rounded,
          animationDelay: 0,
        ),
        const SizedBox(height: 16),
        MeasurementCard(
          jointName: 'Elbow',
          measurementType: elbow != null
              ? _formatType(elbow!.type)
              : 'Waiting...',
          liveValue: elbow?.angle,
          liveSpeed: elbow?.speed,
          accentColor: const Color(0xFFF5A623),
          icon: Icons.turn_slight_left_rounded,
          animationDelay: 100,
        ),
        const SizedBox(height: 16),
        MeasurementCard(
          jointName: 'Wrist',
          measurementType: wrist != null
              ? _formatType(wrist!.type)
              : 'Waiting...',
          liveValue: wrist?.angle,
          liveSpeed: wrist?.speed,
          accentColor: const Color(0xFF50E3C2),
          icon: Icons.pan_tool_alt_rounded,
          animationDelay: 200,
        ),
      ],
    );
  }
}
