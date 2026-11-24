import 'package:engkids/features/forest/models/forest.dart';
import 'package:engkids/features/lessons/models/lesson.dart';
import 'package:engkids/features/matching/models/matching.dart';
import 'package:engkids/features/progress/models/child_progress.dart';

/// Word Matching rules, kept free of Flutter so they're easy to test.
extension MatchingProgress on ChildProgress {
  bool hasMatched(ForestWord w) => matchedWords.contains(w.key);

  bool roundDone(int round) => Matching.rounds[round].every(hasMatched);

  bool get matchedAll => Forest.words.every(hasMatched);

  bool get matchingFinished => completedLessons.contains(Lesson.matching.name);

  /// Where to resume: the first round with an unmatched pair, or round 1.
  int get matchingResumeRound {
    final i = List.generate(
      Matching.rounds.length,
      (r) => r,
    ).indexWhere((r) => !roundDone(r));
    return i < 0 ? 0 : i;
  }

  /// Records a correct match. Coins and the Matching strength go up only
  /// the first time this pair is matched.
  (ChildProgress, int coinsEarned) withPairMatched(ForestWord word) {
    if (hasMatched(word)) return (this, 0);
    final matched = {...matchedWords, word.key};
    return (
      copyWith(
        matchedWords: matched,
        coins: coins + Matching.coinsPerPair,
        strengths: {
          ...strengths,
          Skill.matching: matched.length / Forest.words.length,
        },
      ),
      Matching.coinsPerPair,
    );
  }

  /// Marks Word Matching finished (opening Spell-It Quiz) with the bonus.
  /// Does nothing until every pair is matched, or if already finished.
  (ChildProgress, int coinsEarned) withMatchingFinished() {
    if (!matchedAll || matchingFinished) return (this, 0);
    return (
      copyWith(
        coins: coins + Matching.finishBonus,
        completedLessons: {...completedLessons, Lesson.matching.name},
      ),
      Matching.finishBonus,
    );
  }
}
