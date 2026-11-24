import 'package:engkids/features/forest/models/forest.dart';

/// Word Matching reuses the 20 Haunted Forest words, in rounds of four.
abstract final class Matching {
  static const pairsPerRound = 4;

  /// Rounds in forest order: Moon/Star/Tree/Leaf first, and so on.
  static final List<List<ForestWord>> rounds = [
    for (var i = 0; i < Forest.words.length; i += pairsPerRound)
      Forest.words.sublist(i, i + pairsPerRound),
  ];

  /// Same reward as the other lessons: coins for each new pair matched.
  static const coinsPerPair = 5;

  /// Extra coins for matching every pair (given once).
  static const finishBonus = 20;
}
