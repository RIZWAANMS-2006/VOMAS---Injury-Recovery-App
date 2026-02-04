import 'package:VOMAS/data/models/angles.dart';
import 'package:VOMAS/data/models/vomas_task.dart'; // Adjust path

List<VomasTask> predefinedVomasTasks = [
  VomasTask(
    name: 'Reaching to Shelf',
    description: 'Retrieve light cup; grasp moment.',
    actionType: 'Flexion / Extension',
    shoulder: AngleRange(min: 60, max: 80), // flexion
    elbow: AngleRange(min: 20, max: 40), // flexion
    wrist: AngleRange(min: 5, max: 15), // extension
  ),
  VomasTask(
    name: 'Hanging Towel',
    description: 'Place towel on wall hook.',
    actionType: 'Abduction',
    shoulder: AngleRange(min: 60, max: 80), // abduction
    elbow: AngleRange(min: 20, max: 40), // flexion
    wrist: AngleRange(min: 0, max: 10), // neutral-extension
  ),
  VomasTask(
    name: 'Seatbelt Pull',
    description: 'Reach across body.',
    actionType: 'Horizontal Abduction / Adduction',
    shoulder: AngleRange(min: 20, max: 35), // horizontal adduction
    elbow: AngleRange(min: 10, max: 20), // flexion
    wrist: AngleRange(min: 0, max: 10), // neutral
  ),
  VomasTask(
    name: 'Spoon to Mouth',
    description: 'Bring spoon toward mouth.',
    actionType: 'Flexion / Extension',
    shoulder: AngleRange(min: 30, max: 60), // fixed flexion
    elbow: AngleRange(min: 100, max: 120), // flexion
    wrist: AngleRange(min: 10, max: 20), // extension
  ),
  VomasTask(
    name: 'Cup Lift (Wrist)',
    description: 'Lift small cup using wrist extension.',
    actionType: 'Flexion / Extension',
    shoulder: AngleRange(min: 0, max: 10), // minimal
    elbow: AngleRange(min: 90, max: 90), // ~90 flexion
    wrist: AngleRange(min: 20, max: 40), // extension
  ),
  // Add more as needed from PDF[file:1]
];

// Add this extension at the bottom of vomas_task.dart
extension VomasTaskValidation on VomasTask {
  bool isCorrect(Angles angles) {
    final shoulderMatch =
        shoulder == null ||
        (angles.shoulder.angle >= shoulder!.min &&
            angles.shoulder.angle <= shoulder!.max);

    final elbowMatch =
        elbow == null ||
        (angles.elbow.angle >= elbow!.min && angles.elbow.angle <= elbow!.max);

    final wristMatch =
        wrist == null ||
        (angles.wrist.angle >= wrist!.min && angles.wrist.angle <= wrist!.max);

    return shoulderMatch && elbowMatch && wristMatch;
  }
}
