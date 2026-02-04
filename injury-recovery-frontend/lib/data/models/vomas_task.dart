import 'package:freezed_annotation/freezed_annotation.dart';

part 'vomas_task.freezed.dart';

@freezed
abstract class AngleRange with _$AngleRange {
  const factory AngleRange({required double min, required double max}) =
      _AngleRange;
}

@freezed
abstract class VomasTask with _$VomasTask {
  const VomasTask._();

  const factory VomasTask({
    required String name,
    required String description,
    required String actionType, // Maps to backend action key
    AngleRange? shoulder,
    AngleRange? elbow,
    AngleRange? wrist,
  }) = _VomasTask;
}
