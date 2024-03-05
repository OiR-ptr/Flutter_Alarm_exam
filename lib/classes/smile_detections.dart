import 'package:alarming/classes/alarm_extension_settings.dart';

class SmileDetections {
  final Duration keepDuration;
  final double threshold;

  SmileDetections({required this.keepDuration, required this.threshold});

  static SmileDetections generate(Difficulty difficulty) {
    Duration keepDuration;
    double threshold;

    switch (difficulty) {
      case Difficulty.veryEasy:
        keepDuration = const Duration(seconds: 1);
        threshold = 0.6;
        break;
      case Difficulty.easy:
        keepDuration = const Duration(seconds: 2);
        threshold = 0.7;
        break;
      case Difficulty.normal:
        keepDuration = const Duration(seconds: 3);
        threshold = 0.7;
        break;
      case Difficulty.hard:
        keepDuration = const Duration(seconds: 4);
        threshold = 0.8;
        break;
      case Difficulty.veryHard:
        keepDuration = const Duration(seconds: 5);
        threshold = 0.9;
        break;
    }

    return SmileDetections(
      keepDuration: keepDuration,
      threshold: threshold,
    );
  }
}
