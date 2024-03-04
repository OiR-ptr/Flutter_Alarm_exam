import 'dart:math';

enum Difficulty {
  veryEasy,
  easy,
  normal,
  hard,
  veryHard,
}

class MathQuestions {
  final String questions;
  final int answer;

  MathQuestions({required this.questions, required this.answer});

  static MathQuestions generate(Difficulty difficulty) {
    final generator = Random();
    final List<int> numbers = [];

    switch(difficulty) {
      case Difficulty.veryEasy:
        numbers.add(generator.nextInt(10));
        numbers.add(generator.nextInt(10));
        break;
      case Difficulty.easy:
        numbers.add(generator.nextInt(50));
        numbers.add(generator.nextInt(50));
        break;
      case Difficulty.normal:
        numbers.add(generator.nextInt(100));
        numbers.add(generator.nextInt(50));
        numbers.add(generator.nextInt(10));
        break;
      case Difficulty.hard:
        numbers.add(generator.nextInt(1000));
        numbers.add(generator.nextInt(100));
        numbers.add(generator.nextInt(100));
        break;
      case Difficulty.veryHard:
        numbers.add(generator.nextInt(1000));
        numbers.add(generator.nextInt(1000));
        numbers.add(generator.nextInt(1000));
        break;
    }

    return MathQuestions(
      questions: numbers.join(' + '),
      answer: numbers.fold(0, (prev, current) => prev + current),
    );
  }
}