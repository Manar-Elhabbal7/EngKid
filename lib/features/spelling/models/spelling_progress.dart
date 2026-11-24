import 'package:engkids/features/forest/models/forest.dart';
import 'package:engkids/features/lessons/models/lesson.dart';
import 'package:engkids/features/progress/models/child_progress.dart';
import 'package:engkids/features/spelling/models/spelling.dart';

/// Spell-It Quiz rules, kept free of Flutter so they're easy to test.
extension SpellingProgress on ChildProgress {
  bool hasSpelled(ForestWord w) => spelledWords.contains(w.key);

  bool get spelledAll => Spelling.words.every(hasSpelled);

  bool get spellingFinished => completedLessons.contains(Lesson.quiz.name);

  /// Where to resume: the first word not spelled yet, or the first word.
  int get spellingResumeIndex {
    final i = Spelling.words.indexWhere((w) => !hasSpelled(w));
    return i < 0 ? 0 : i;
  }

  /// Records a word spelled all the way through. Coins and the Spelling
  /// strength go up only the first time.
  (ChildProgress, int coinsEarned) withWordSpelled(ForestWord word) {
    if (hasSpelled(word)) return (this, 0);
    final spelled = {...spelledWords, word.key};
    return (
      copyWith(
        spelledWords: spelled,
        coins: coins + Spelling.coinsPerWord,
        strengths: {
          ...strengths,
          Skill.spelling: spelled.length / Spelling.words.length,
        },
      ),
      Spelling.coinsPerWord,
    );
  }

  /// Marks the quiz finished (opening Magic Cauldron) with the bonus.
  /// Does nothing until every word is spelled, or if already finished.
  (ChildProgress, int coinsEarned) withSpellingFinished() {
    if (!spelledAll || spellingFinished) return (this, 0);
    return (
      copyWith(
        coins: coins + Spelling.finishBonus,
        completedLessons: {...completedLessons, Lesson.quiz.name},
      ),
      Spelling.finishBonus,
    );
  }
}
