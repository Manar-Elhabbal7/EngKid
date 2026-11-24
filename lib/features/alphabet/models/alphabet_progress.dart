import 'package:engkids/features/alphabet/models/alphabet.dart';
import 'package:engkids/features/lessons/models/lesson.dart';
import 'package:engkids/features/progress/models/child_progress.dart';

/// Alphabet Adventure rules, kept free of Flutter so they're easy to test.
extension AlphabetProgress on ChildProgress {
  bool hasHeard(AlphabetLetter l) => heardLetters.contains(l.key);

  bool get heardAllLetters =>
      Alphabet.letters.every((l) => heardLetters.contains(l.key));

  bool get alphabetFinished => completedLessons.contains(Lesson.alphabet.name);

  /// Where to resume: the first letter not heard yet, or A when all are.
  int get alphabetResumeIndex {
    final i = Alphabet.letters.indexWhere((l) => !hasHeard(l));
    return i < 0 ? 0 : i;
  }

  /// Records that [letter] was heard all the way through.
  /// Coins and progress go up only the first time.
  (ChildProgress, int coinsEarned) withLetterHeard(AlphabetLetter letter) {
    if (hasHeard(letter)) return (this, 0);
    final heard = {...heardLetters, letter.key};
    return (
      copyWith(
        heardLetters: heard,
        lettersLearned: heard.length,
        coins: coins + Alphabet.coinsPerLetter,
        strengths: {
          ...strengths,
          Skill.alphabet: heard.length / Alphabet.letters.length,
        },
      ),
      Alphabet.coinsPerLetter,
    );
  }

  /// Marks the lesson finished (opening Haunted Forest) and gives the bonus.
  /// Does nothing until every letter is heard, or if already finished.
  (ChildProgress, int coinsEarned) withAlphabetFinished() {
    if (!heardAllLetters || alphabetFinished) return (this, 0);
    return (
      copyWith(
        coins: coins + Alphabet.finishBonus,
        completedLessons: {...completedLessons, Lesson.alphabet.name},
      ),
      Alphabet.finishBonus,
    );
  }
}
