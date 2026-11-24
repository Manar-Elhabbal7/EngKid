/// One letter of Alphabet Adventure and the word Boo uses for it.
class AlphabetLetter {
  const AlphabetLetter(this.letter, this.word);

  /// Uppercase letter, e.g. "A".
  final String letter;

  /// Example word, e.g. "Apple".
  final String word;

  /// Lowercase key used when saving progress.
  String get key => letter.toLowerCase();

  /// Recorded voice for this letter, e.g. `assets/audio/letters/A.mp3`.
  String get audioAsset => 'assets/audio/letters/$letter.mp3';

  /// What the phone's voice says when there's no recorded audio file.
  String get spoken => '$letter. $letter is for $word.';
}

abstract final class Alphabet {
  static const letters = <AlphabetLetter>[
    AlphabetLetter('A', 'Apple'),
    AlphabetLetter('B', 'Bat'),
    AlphabetLetter('C', 'Cat'),
    AlphabetLetter('D', 'Dog'),
    AlphabetLetter('E', 'Egg'),
    AlphabetLetter('F', 'Fox'),
    AlphabetLetter('G', 'Ghost'),
    AlphabetLetter('H', 'Hat'),
    AlphabetLetter('I', 'Ice cream'),
    AlphabetLetter('J', 'Jam'),
    AlphabetLetter('K', 'Kite'),
    AlphabetLetter('L', 'Lion'),
    AlphabetLetter('M', 'Moon'),
    AlphabetLetter('N', 'Nest'),
    AlphabetLetter('O', 'Owl'),
    AlphabetLetter('P', 'Pumpkin'),
    AlphabetLetter('Q', 'Queen'),
    AlphabetLetter('R', 'Rainbow'),
    AlphabetLetter('S', 'Spider'),
    AlphabetLetter('T', 'Tiger'),
    AlphabetLetter('U', 'Umbrella'),
    AlphabetLetter('V', 'Vampire'),
    AlphabetLetter('W', 'Witch'),
    AlphabetLetter('X', 'Xylophone'),
    AlphabetLetter('Y', 'Yo-yo'),
    AlphabetLetter('Z', 'Zebra'),
  ];

  /// Coins for hearing a letter for the first time.
  static const coinsPerLetter = 5;

  /// Extra coins for finishing all 26 letters (given once).
  static const finishBonus = 20;
}
