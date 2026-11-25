/// The lessons on the "Choose a game" screen, in the order a child plays
/// them. Each one opens after the one before it is finished.
enum Lesson {
  alphabet('Alphabet Adventure', '🎃'),
  forest('Haunted Forest', '👻'),
  matching('Word Matching', '🧩'),
  quiz('Spell-It Quiz', '❓'),
  // 🧪 rather than 🫧: many emoji fonts (older Android, Linux) lack 🫧
  // and show nothing. The row on "Choose a game" uses the cauldron picture.
  cauldron('Magic Cauldron', '🧪', icon: 'assets/images/cauldron.png');

  const Lesson(this.title, this.emoji, {this.icon});

  final String title;

  /// Used in text, e.g. "🧪 Magic Cauldron is now open!".
  final String emoji;

  /// Optional picture shown instead of [emoji] on the lesson list.
  final String? icon;

  /// The lesson that must be finished first, or null for the first lesson.
  Lesson? get previous => index == 0 ? null : Lesson.values[index - 1];

  /// [completed] holds the names of finished lessons (see `Lesson.name`).
  bool isUnlocked(Set<String> completed) {
    final before = previous;
    return before == null || completed.contains(before.name);
  }
}
