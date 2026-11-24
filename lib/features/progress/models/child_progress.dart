/// The four skills shown under "Activity Strengths".
enum Skill {
  alphabet('Alphabet'),
  vocabulary('Vocabulary'),
  matching('Matching'),
  spelling('Spelling');

  const Skill(this.label);
  final String label;
}

/// One child's learning progress. Everything starts at zero; the games
/// update it as the child plays.
class ChildProgress {
  const ChildProgress({
    this.lettersLearned = 0,
    this.wordsLearned = 0,
    this.secondsPlayed = 0,
    this.strengths = const {},
    this.completedLessons = const {},
    this.coins = 0,
    this.heardLetters = const {},
    this.heardWords = const {},
    this.matchedWords = const {},
    this.spelledWords = const {},
  });

  static const empty = ChildProgress();

  final int lettersLearned;
  final int wordsLearned;
  final int secondsPlayed;

  /// 0.0 – 1.0 per skill. Missing skills count as 0.
  final Map<Skill, double> strengths;

  /// Names of finished lessons (`Lesson.name`), e.g. `{'alphabet'}`.
  final Set<String> completedLessons;

  /// Coins earned in the games.
  final int coins;

  /// Letters heard at least once, lowercase (`{'a', 'b'}`). Used so coins
  /// are only given the first time.
  final Set<String> heardLetters;

  /// Haunted Forest words heard at least once, lowercase (`{'owl'}`).
  final Set<String> heardWords;

  /// Word Matching pairs matched at least once, lowercase (`{'owl'}`).
  final Set<String> matchedWords;

  /// Spell-It Quiz words spelled at least once, lowercase (`{'owl'}`).
  final Set<String> spelledWords;

  double strength(Skill skill) => (strengths[skill] ?? 0).clamp(0.0, 1.0);

  bool get isEmpty =>
      lettersLearned == 0 &&
      wordsLearned == 0 &&
      secondsPlayed == 0 &&
      completedLessons.isEmpty &&
      coins == 0 &&
      Skill.values.every((s) => strength(s) == 0);

  /// "1h 24m", "12m", or "0m".
  String get timePlayedLabel {
    final minutes = secondsPlayed ~/ 60;
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  ChildProgress copyWith({
    int? lettersLearned,
    int? wordsLearned,
    int? secondsPlayed,
    Map<Skill, double>? strengths,
    Set<String>? completedLessons,
    int? coins,
    Set<String>? heardLetters,
    Set<String>? heardWords,
    Set<String>? matchedWords,
    Set<String>? spelledWords,
  }) {
    return ChildProgress(
      lettersLearned: lettersLearned ?? this.lettersLearned,
      wordsLearned: wordsLearned ?? this.wordsLearned,
      secondsPlayed: secondsPlayed ?? this.secondsPlayed,
      strengths: strengths ?? this.strengths,
      completedLessons: completedLessons ?? this.completedLessons,
      coins: coins ?? this.coins,
      heardLetters: heardLetters ?? this.heardLetters,
      heardWords: heardWords ?? this.heardWords,
      matchedWords: matchedWords ?? this.matchedWords,
      spelledWords: spelledWords ?? this.spelledWords,
    );
  }

  Map<String, Object> toMap() => {
    'letters': lettersLearned,
    'words': wordsLearned,
    'seconds': secondsPlayed,
    for (final s in Skill.values) 'skill_${s.name}': strength(s),
    'completed': completedLessons.toList(),
    'coins': coins,
    'heard': heardLetters.toList(),
    'words_heard': heardWords.toList(),
    'matched': matchedWords.toList(),
    'spelled': spelledWords.toList(),
  };

  /// Bad or missing values become 0 so a corrupt save can't crash the app.
  static ChildProgress fromMap(Object? raw) {
    if (raw is! Map) return empty;
    int count(String key) {
      final v = raw[key];
      return v is num && v >= 0 ? v.toInt() : 0;
    }

    return ChildProgress(
      lettersLearned: count('letters'),
      wordsLearned: count('words'),
      secondsPlayed: count('seconds'),
      strengths: {
        for (final s in Skill.values)
          if (raw['skill_${s.name}'] case final num v)
            s: v.toDouble().clamp(0.0, 1.0),
      },
      completedLessons: {
        if (raw['completed'] case final List list) ...list.whereType<String>(),
      },
      coins: count('coins'),
      heardLetters: {
        if (raw['heard'] case final List list) ...list.whereType<String>(),
      },
      heardWords: {
        if (raw['words_heard'] case final List list)
          ...list.whereType<String>(),
      },
      matchedWords: {
        if (raw['matched'] case final List list) ...list.whereType<String>(),
      },
      spelledWords: {
        if (raw['spelled'] case final List list) ...list.whereType<String>(),
      },
    );
  }
}
