import 'package:flutter/material.dart';
import 'package:VOMAS/data/models/angles.dart';

class SingleMeasurementCard extends StatelessWidget {
  final JointMeasurement? shoulder;
  final JointMeasurement? elbow;
  final JointMeasurement? wrist;

  const SingleMeasurementCard({
    super.key,
    this.shoulder,
    this.elbow,
    this.wrist,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2A3E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _buildColumn(
                context,
                title: 'Shoulder',
                data: shoulder,
                color: const Color(0xFF4A90E2),
              ),
            ),
            _buildDivider(),
            Expanded(
              child: _buildColumn(
                context,
                title: 'Elbow',
                data: elbow,
                color: const Color(0xFF50E3C2),
              ),
            ),
            _buildDivider(),
            Expanded(
              child: _buildColumn(
                context,
                title: 'Wrist',
                data: wrist,
                color: const Color(0xFFF5A623),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildColumn(
    BuildContext context, {
    required String title,
    required JointMeasurement? data,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final hasData = data != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Speed
              Column(
                children: [
                  Text(
                    'Speed',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasData ? data.speed.toStringAsFixed(1) : '--',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Angle
              Column(
                children: [
                  Text(
                    'Angle',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasData ? data.angle.toStringAsFixed(1) : '--',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (hasData)
                        Text(
                          '°',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
