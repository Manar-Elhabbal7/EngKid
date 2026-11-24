/// The lessons on the "Choose a game" screen, in the order a child plays
/// them. Each one opens after the one before it is finished.
enum Lesson {
  alphabet('Alphabet Adventure', '🎃'),
  forest('Haunted Forest', '👻'),
  matching('Word Matching', '🧩'),
  quiz('Spell-It Quiz', '❓'),
  cauldron('Magic Cauldron', '🫧');

  const Lesson(this.title, this.emoji);

  final String title;
  final String emoji;

  /// The lesson that must be finished first, or null for the first lesson.
  Lesson? get previous => index == 0 ? null : Lesson.values[index - 1];

  /// [completed] holds the names of finished lessons (see `Lesson.name`).
  bool isUnlocked(Set<String> completed) {
    final before = previous;
    return before == null || completed.contains(before.name);
  }
}
