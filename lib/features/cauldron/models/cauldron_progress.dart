import 'package:engkids/features/cauldron/models/cauldron.dart';
import 'package:engkids/features/forest/models/forest.dart';
import 'package:engkids/features/lessons/models/lesson.dart';
import 'package:engkids/features/progress/models/child_progress.dart';

/// Magic Cauldron rules, kept free of Flutter so they're easy to test.
extension CauldronProgress on ChildProgress {
  bool hasBrewed(ForestWord w) => brewedWords.contains(w.key);

  bool get brewedAll => Cauldron.ingredients.every(hasBrewed);

  bool get cauldronFinished => completedLessons.contains(Lesson.cauldron.name);

  /// Where to resume: the first ingredient not found yet, or the first.
  int get cauldronResumeIndex {
    final i = Cauldron.ingredients.indexWhere((w) => !hasBrewed(w));
    return i < 0 ? 0 : i;
  }

  /// Records a correct ingredient. Coins only the first time.
  (ChildProgress, int coinsEarned) withIngredientBrewed(ForestWord word) {
    if (hasBrewed(word)) return (this, 0);
    return (
      copyWith(
        brewedWords: {...brewedWords, word.key},
        coins: coins + Cauldron.coinsPerIngredient,
      ),
      Cauldron.coinsPerIngredient,
    );
  }

  /// Marks the cauldron (the last lesson) finished with the bonus.
  /// Does nothing until every ingredient is found, or if already finished.
  (ChildProgress, int coinsEarned) withPotionBrewed() {
    if (!brewedAll || cauldronFinished) return (this, 0);
    return (
      copyWith(
        coins: coins + Cauldron.finishBonus,
        completedLessons: {...completedLessons, Lesson.cauldron.name},
      ),
      Cauldron.finishBonus,
    );
  }
}
