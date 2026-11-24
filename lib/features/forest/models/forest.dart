/// One word hidden in the Haunted Forest, with the picture that shows it.
class ForestWord {
  const ForestWord(this.word, this.emoji);

  /// e.g. "Owl".
  final String word;

  /// The picture on the front of the card, e.g. 🦉.
  final String emoji;

  /// Lowercase key used when saving progress.
  String get key => word.toLowerCase();
}

abstract final class Forest {
  /// Things a child meets on a spooky night walk, easiest first.
  static const words = <ForestWord>[
    ForestWord('Moon', '🌙'),
    ForestWord('Star', '⭐'),
    ForestWord('Tree', '🌳'),
    ForestWord('Leaf', '🍂'),
    ForestWord('Owl', '🦉'),
    ForestWord('Bat', '🦇'),
    ForestWord('Cat', '🐱'),
    ForestWord('Frog', '🐸'),
    ForestWord('Wolf', '🐺'),
    ForestWord('Spider', '🕷️'),
    ForestWord('Mushroom', '🍄'),
    ForestWord('Apple', '🍎'),
    ForestWord('Pumpkin', '🎃'),
    ForestWord('Candy', '🍬'),
    ForestWord('Candle', '🕯️'),
    ForestWord('Ghost', '👻'),
    ForestWord('Witch', '🧙'),
    ForestWord('Broom', '🧹'),
    ForestWord('Hat', '🎩'),
    ForestWord('Castle', '🏰'),
  ];

  /// Same reward as a letter: coins for the first full listen of a word.
  static const coinsPerWord = 5;

  /// Extra coins for finishing every word (given once).
  static const finishBonus = 20;
}
