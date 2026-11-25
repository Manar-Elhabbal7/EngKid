import 'dart:math' as math;

import 'package:engkids/features/forest/models/forest.dart';

/// Magic Cauldron: Boo says an ingredient, the child finds it among three
/// and drops it in. Reviews the Haunted Forest words by listening.
abstract final class Cauldron {
  static const _keys = [
    'bat',
    'spider',
    'frog',
    'mushroom',
    'leaf',
    'apple',
    'candy',
    'pumpkin',
    'candle',
    'ghost',
  ];

  static final List<ForestWord> ingredients = [
    for (final k in _keys) Forest.words.firstWhere((w) => w.key == k),
  ];

  static const choicesPerRound = 3;

  /// Same reward as the other lessons: coins for each new ingredient found.
  static const coinsPerIngredient = 5;

  /// Extra coins for brewing the whole potion (given once).
  static const finishBonus = 20;

  /// [target] plus two other forest words, in a random order.
  static List<ForestWord> choicesFor(ForestWord target, math.Random rng) {
    final others = Forest.words.where((w) => w != target).toList()
      ..shuffle(rng);
    return [target, ...others.take(choicesPerRound - 1)]..shuffle(rng);
  }
}
