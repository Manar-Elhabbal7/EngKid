import 'package:flutter/material.dart' show Color;

/// One vocabulary word entry.
class VocabWord {
  const VocabWord({
    required this.word,
    required this.emoji,
    required this.category,
  });

  final String word;

  /// Emoji used as the visual on the front of the flashcard.
  final String emoji;

  final String category;

  /// TTS phrase Boo speaks when the card is tapped.
  String get ttsPhrase => word;
}

/// One vocabulary category with its display metadata.
class VocabCategory {
  const VocabCategory({
    required this.id,
    required this.label,
    required this.emoji,
    required this.color,
    required this.words,
  });

  final String id;
  final String label;
  final String emoji;
  final Color color;
  final List<VocabWord> words;
}

/// All 10 categories and 50 words.
class VocabData {
  VocabData._();

  static const List<VocabCategory> categories = [
    VocabCategory(
      id: 'animals',
      label: 'Animals',
      emoji: '🐾',
      color: Color(0xFF8B4513),
      words: [
        VocabWord(word: 'Cat',      emoji: '🐱', category: 'Animals'),
        VocabWord(word: 'Dog',      emoji: '🐶', category: 'Animals'),
        VocabWord(word: 'Frog',     emoji: '🐸', category: 'Animals'),
        VocabWord(word: 'Owl',      emoji: '🦉', category: 'Animals'),
        VocabWord(word: 'Bat',      emoji: '🦇', category: 'Animals'),
      ],
    ),
    VocabCategory(
      id: 'colors',
      label: 'Colors',
      emoji: '🌈',
      color: Color(0xFFE91E63),
      words: [
        VocabWord(word: 'Red',    emoji: '🔴', category: 'Colors'),
        VocabWord(word: 'Blue',   emoji: '🔵', category: 'Colors'),
        VocabWord(word: 'Green',  emoji: '🟢', category: 'Colors'),
        VocabWord(word: 'Yellow', emoji: '🟡', category: 'Colors'),
        VocabWord(word: 'Purple', emoji: '🟣', category: 'Colors'),
      ],
    ),
    VocabCategory(
      id: 'numbers',
      label: 'Numbers',
      emoji: '🔢',
      color: Color(0xFF1976D2),
      words: [
        VocabWord(word: 'One',   emoji: '1️⃣', category: 'Numbers'),
        VocabWord(word: 'Two',   emoji: '2️⃣', category: 'Numbers'),
        VocabWord(word: 'Three', emoji: '3️⃣', category: 'Numbers'),
        VocabWord(word: 'Four',  emoji: '4️⃣', category: 'Numbers'),
        VocabWord(word: 'Five',  emoji: '5️⃣', category: 'Numbers'),
      ],
    ),
    VocabCategory(
      id: 'body',
      label: 'Body Parts',
      emoji: '🫀',
      color: Color(0xFFD32F2F),
      words: [
        VocabWord(word: 'Eye',    emoji: '👁️', category: 'Body Parts'),
        VocabWord(word: 'Nose',   emoji: '👃',  category: 'Body Parts'),
        VocabWord(word: 'Hand',   emoji: '✋',  category: 'Body Parts'),
        VocabWord(word: 'Foot',   emoji: '🦶',  category: 'Body Parts'),
        VocabWord(word: 'Ear',    emoji: '👂',  category: 'Body Parts'),
      ],
    ),
    VocabCategory(
      id: 'halloween',
      label: 'Halloween',
      emoji: '🎃',
      color: Color(0xFFFF6B00),
      words: [
        VocabWord(word: 'Ghost',   emoji: '👻', category: 'Halloween'),
        VocabWord(word: 'Witch',   emoji: '🧙', category: 'Halloween'),
        VocabWord(word: 'Pumpkin', emoji: '🎃', category: 'Halloween'),
        VocabWord(word: 'Bat',     emoji: '🦇', category: 'Halloween'),
        VocabWord(word: 'Spider',  emoji: '🕷️', category: 'Halloween'),
      ],
    ),
    VocabCategory(
      id: 'fruits',
      label: 'Fruits',
      emoji: '🍎',
      color: Color(0xFF388E3C),
      words: [
        VocabWord(word: 'Apple',  emoji: '🍎', category: 'Fruits'),
        VocabWord(word: 'Banana', emoji: '🍌', category: 'Fruits'),
        VocabWord(word: 'Grape',  emoji: '🍇', category: 'Fruits'),
        VocabWord(word: 'Orange', emoji: '🍊', category: 'Fruits'),
        VocabWord(word: 'Lemon',  emoji: '🍋', category: 'Fruits'),
      ],
    ),
    VocabCategory(
      id: 'shapes',
      label: 'Shapes',
      emoji: '🔷',
      color: Color(0xFF7B1FA2),
      words: [
        VocabWord(word: 'Circle',   emoji: '⭕', category: 'Shapes'),
        VocabWord(word: 'Square',   emoji: '🟥', category: 'Shapes'),
        VocabWord(word: 'Triangle', emoji: '🔺', category: 'Shapes'),
        VocabWord(word: 'Star',     emoji: '⭐', category: 'Shapes'),
        VocabWord(word: 'Heart',    emoji: '❤️', category: 'Shapes'),
      ],
    ),
    VocabCategory(
      id: 'family',
      label: 'Family',
      emoji: '👨‍👩‍👧',
      color: Color(0xFF00796B),
      words: [
        VocabWord(word: 'Mom',     emoji: '👩', category: 'Family'),
        VocabWord(word: 'Dad',     emoji: '👨', category: 'Family'),
        VocabWord(word: 'Baby',    emoji: '👶', category: 'Family'),
        VocabWord(word: 'Sister',  emoji: '👧', category: 'Family'),
        VocabWord(word: 'Brother', emoji: '👦', category: 'Family'),
      ],
    ),
    VocabCategory(
      id: 'weather',
      label: 'Weather',
      emoji: '⛅',
      color: Color(0xFF0288D1),
      words: [
        VocabWord(word: 'Sun',   emoji: '☀️',  category: 'Weather'),
        VocabWord(word: 'Rain',  emoji: '🌧️',  category: 'Weather'),
        VocabWord(word: 'Snow',  emoji: '❄️',  category: 'Weather'),
        VocabWord(word: 'Wind',  emoji: '💨',  category: 'Weather'),
        VocabWord(word: 'Cloud', emoji: '☁️',  category: 'Weather'),
      ],
    ),
    VocabCategory(
      id: 'actions',
      label: 'Actions',
      emoji: '🏃',
      color: Color(0xFFF57C00),
      words: [
        VocabWord(word: 'Run',   emoji: '🏃', category: 'Actions'),
        VocabWord(word: 'Jump',  emoji: '🦘', category: 'Actions'),
        VocabWord(word: 'Swim',  emoji: '🏊', category: 'Actions'),
        VocabWord(word: 'Eat',   emoji: '😋', category: 'Actions'),
        VocabWord(word: 'Sleep', emoji: '😴', category: 'Actions'),
      ],
    ),
  ];

  /// All 50 words flattened — used by the matching game and quiz.
  static List<VocabWord> get allWords =>
      categories.expand((c) => c.words).toList();
}
