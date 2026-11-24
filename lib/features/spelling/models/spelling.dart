import 'package:engkids/features/forest/models/forest.dart';

/// Spell-It Quiz: short Haunted Forest words (3–4 letters) the child
/// already knows, spelled with letter pumpkins.
abstract final class Spelling {
  static const _keys = [
    'owl',
    'bat',
    'cat',
    'hat',
    'moon',
    'star',
    'tree',
    'leaf',
    'frog',
    'wolf',
  ];

  static final List<ForestWord> words = [
    for (final k in _keys) Forest.words.firstWhere((w) => w.key == k),
  ];

  /// Same reward as the other lessons: coins for each new word spelled.
  static const coinsPerWord = 5;

  /// Extra coins for spelling every word (given once).
  static const finishBonus = 20;

  /// Wrong taps on one letter before the right pumpkin starts glowing.
  static const hintAfterMistakes = 2;
}
