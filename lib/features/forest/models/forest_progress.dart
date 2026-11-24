import 'package:engkids/features/forest/models/forest.dart';
import 'package:engkids/features/lessons/models/lesson.dart';
import 'package:engkids/features/progress/models/child_progress.dart';

/// Haunted Forest rules, kept free of Flutter so they're easy to test.
extension ForestProgress on ChildProgress {
  bool hasHeardWord(ForestWord w) => heardWords.contains(w.key);

  bool get heardAllWords =>
      Forest.words.every((w) => heardWords.contains(w.key));

  bool get forestFinished => completedLessons.contains(Lesson.forest.name);

  /// Where to resume: the first word not heard yet, or the first word.
  int get forestResumeIndex {
    final i = Forest.words.indexWhere((w) => !hasHeardWord(w));
    return i < 0 ? 0 : i;
  }

  /// Records that [word] was heard all the way through.
  /// Coins, "Words Learned" and Vocabulary go up only the first time.
  (ChildProgress, int coinsEarned) withWordHeard(ForestWord word) {
    if (hasHeardWord(word)) return (this, 0);
    final heard = {...heardWords, word.key};
    return (
      copyWith(
        heardWords: heard,
        wordsLearned: heard.length,
        coins: coins + Forest.coinsPerWord,
        strengths: {
          ...strengths,
          Skill.vocabulary: heard.length / Forest.words.length,
        },
      ),
      Forest.coinsPerWord,
    );
  }

  /// Marks the forest finished (opening Word Matching) and gives the bonus.
  /// Does nothing until every word is heard, or if already finished.
  (ChildProgress, int coinsEarned) withForestFinished() {
    if (!heardAllWords || forestFinished) return (this, 0);
    return (
      copyWith(
        coins: coins + Forest.finishBonus,
        completedLessons: {...completedLessons, Lesson.forest.name},
      ),
      Forest.finishBonus,
    );
  }
}
