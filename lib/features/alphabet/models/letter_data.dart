/// One entry in the A–Z alphabet.
class LetterEntry {
  const LetterEntry({
    required this.letter,
    required this.word,
    required this.emoji,
  });

  /// The uppercase letter, e.g. "A".
  final String letter;

  /// Example English word starting with this letter, e.g. "Apple".
  final String word;

  /// An emoji that represents the word visually.
  final String emoji;

  /// The full TTS phrase Boo will say.
  String get ttsPhrase => '$letter is for $word';
}

/// All 26 letters with a child-friendly word and emoji.
const List<LetterEntry> kAlphabet = [
  LetterEntry(letter: 'A', word: 'Apple',    emoji: '🍎'),
  LetterEntry(letter: 'B', word: 'Bat',      emoji: '🦇'),
  LetterEntry(letter: 'C', word: 'Cat',      emoji: '🐱'),
  LetterEntry(letter: 'D', word: 'Dog',      emoji: '🐶'),
  LetterEntry(letter: 'E', word: 'Elephant', emoji: '🐘'),
  LetterEntry(letter: 'F', word: 'Fox',      emoji: '🦊'),
  LetterEntry(letter: 'G', word: 'Ghost',    emoji: '👻'),
  LetterEntry(letter: 'H', word: 'Hat',      emoji: '🎩'),
  LetterEntry(letter: 'I', word: 'Ice Cream',emoji: '🍦'),
  LetterEntry(letter: 'J', word: 'Jellyfish',emoji: '🪼'),
  LetterEntry(letter: 'K', word: 'Kite',     emoji: '🪁'),
  LetterEntry(letter: 'L', word: 'Lion',     emoji: '🦁'),
  LetterEntry(letter: 'M', word: 'Moon',     emoji: '🌙'),
  LetterEntry(letter: 'N', word: 'Ninja',    emoji: '🥷'),
  LetterEntry(letter: 'O', word: 'Owl',      emoji: '🦉'),
  LetterEntry(letter: 'P', word: 'Pumpkin',  emoji: '🎃'),
  LetterEntry(letter: 'Q', word: 'Queen',    emoji: '👸'),
  LetterEntry(letter: 'R', word: 'Rainbow',  emoji: '🌈'),
  LetterEntry(letter: 'S', word: 'Spider',   emoji: '🕷️'),
  LetterEntry(letter: 'T', word: 'Tiger',    emoji: '🐯'),
  LetterEntry(letter: 'U', word: 'Umbrella', emoji: '☂️'),
  LetterEntry(letter: 'V', word: 'Vampire',  emoji: '🧛'),
  LetterEntry(letter: 'W', word: 'Witch',    emoji: '🧙'),
  LetterEntry(letter: 'X', word: 'X-ray',    emoji: '🩻'),
  LetterEntry(letter: 'Y', word: 'Yak',      emoji: '🐃'),
  LetterEntry(letter: 'Z', word: 'Zombie',   emoji: '🧟'),
];
