import 'dart:math';
import '../../vocabulary/models/vocab_data.dart';

/// One quiz question: show [emoji], pick the correct [answer] from [choices].
class QuizQuestion {
  const QuizQuestion({
    required this.emoji,
    required this.answer,
    required this.choices,
  });

  /// The emoji shown as the visual prompt.
  final String emoji;

  /// The correct word.
  final String answer;

  /// Four word options (includes the correct one).
  final List<String> choices;
}

/// Result after the player taps a choice.
enum AnswerResult { correct, wrong }

/// Drives the quiz: generates questions, tracks score and streak.
class QuizEngine {
  QuizEngine({int? seed, this.totalQuestions = 10})
      : _rng = Random(seed),
        _score = 0,
        _streak = 0,
        _maxStreak = 0,
        _answered = 0 {
    _questions = _buildQuestions();
  }

  final Random _rng;
  final int totalQuestions;

  late final List<QuizQuestion> _questions;
  int _current = 0;
  int _score;
  int _streak;
  int _maxStreak;
  int _answered;

  int get score => _score;
  int get streak => _streak;
  int get maxStreak => _maxStreak;
  int get answered => _answered;
  bool get isFinished => _current >= _questions.length;
  QuizQuestion get current => _questions[_current];

  /// Call after the player picks a choice. Returns the result.
  AnswerResult submit(String choice) {
    _answered++;
    if (choice == current.answer) {
      _score++;
      _streak++;
      if (_streak > _maxStreak) _maxStreak = _streak;
      _current++;
      return AnswerResult.correct;
    } else {
      _streak = 0;
      _current++;
      return AnswerResult.wrong;
    }
  }

  // ── Question builder ────────────────────────────────────────────────────

  List<QuizQuestion> _buildQuestions() {
    // Deduplicate pool by word (same fix as matching game).
    final seen = <String>{};
    final pool = VocabData.allWords
        .where((w) => seen.add(w.word))
        .toList()
      ..shuffle(_rng);

    final count = min(totalQuestions, pool.length);
    final selected = pool.sublist(0, count);

    return selected.map((target) {
      // Pick 3 distractors from the rest of the pool.
      final others = pool.where((w) => w.word != target.word).toList()
        ..shuffle(_rng);
      final distractors = others.take(3).map((w) => w.word).toList();
      final choices = [...distractors, target.word]..shuffle(_rng);

      return QuizQuestion(
        emoji: target.emoji,
        answer: target.word,
        choices: choices,
      );
    }).toList();
  }
}
