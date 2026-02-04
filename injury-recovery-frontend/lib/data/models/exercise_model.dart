import 'package:VOMAS/data/models/vomas_task.dart';

class Exercise {
  final String title;
  final String description;
  final String duration;
  final int repetitions;
  final VomasTask vomasTask; // Add this for navigation

  Exercise({
    required this.title,
    required this.description,
    required this.duration,
    required this.repetitions,
    required this.vomasTask,
  });
}
