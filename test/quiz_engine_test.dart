import 'package:flutter_test/flutter_test.dart';
import 'package:engkids/features/quiz/models/quiz_engine.dart';

void main() {
  group('QuizEngine', () {
    test('generates the requested number of questions', () {
      final engine = QuizEngine(seed: 1, totalQuestions: 10);
      expect(engine.totalQuestions, 10);
    });

    test('each question has exactly 4 choices', () {
      final engine = QuizEngine(seed: 1, totalQuestions: 10);
      for (var i = 0; i < 10; i++) {
        expect(engine.current.choices.length, 4);
        engine.submit(engine.current.choices.first);
      }
    });

    test('correct answer is always among the choices', () {
      final engine = QuizEngine(seed: 2, totalQuestions: 10);
      for (var i = 0; i < 10; i++) {
        expect(
          engine.current.choices,
          contains(engine.current.answer),
        );
        engine.submit(engine.current.choices.first);
      }
    });

    test('correct submission increments score and streak', () {
      final engine = QuizEngine(seed: 3, totalQuestions: 5);
      final result = engine.submit(engine.current.answer);
      expect(result, AnswerResult.correct);
      expect(engine.score, 1);
      expect(engine.streak, 1);
    });

    test('wrong submission resets streak but does not increment score', () {
      final engine = QuizEngine(seed: 3, totalQuestions: 5);
      // First get one correct to build streak.
      engine.submit(engine.current.answer);
      expect(engine.streak, 1);
      // Now answer wrong.
      final wrongChoice = engine.current.choices
          .firstWhere((c) => c != engine.current.answer);
      final result = engine.submit(wrongChoice);
      expect(result, AnswerResult.wrong);
      expect(engine.streak, 0);
      expect(engine.score, 1); // unchanged
    });

    test('maxStreak tracks the highest streak seen', () {
      final engine = QuizEngine(seed: 4, totalQuestions: 10);
      // Answer all correctly.
      while (!engine.isFinished) {
        engine.submit(engine.current.answer);
      }
      expect(engine.maxStreak, 10);
      expect(engine.score, 10);
    });

    test('isFinished after answering all questions', () {
      final engine = QuizEngine(seed: 5, totalQuestions: 5);
      expect(engine.isFinished, isFalse);
      for (var i = 0; i < 5; i++) {
        engine.submit(engine.current.choices.first);
      }
      expect(engine.isFinished, isTrue);
    });

    test('no duplicate question answers across a session', () {
      final engine = QuizEngine(seed: 6, totalQuestions: 10);
      final answers = <String>[];
      while (!engine.isFinished) {
        answers.add(engine.current.answer);
        engine.submit(engine.current.choices.first);
      }
      expect(answers.toSet().length, answers.length);
    });
  });
}
