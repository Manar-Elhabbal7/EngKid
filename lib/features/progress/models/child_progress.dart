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
  });

  static const empty = ChildProgress();

  final int lettersLearned;
  final int wordsLearned;
  final int secondsPlayed;

  /// 0.0 – 1.0 per skill. Missing skills count as 0.
  final Map<Skill, double> strengths;

  double strength(Skill skill) => (strengths[skill] ?? 0).clamp(0.0, 1.0);

  bool get isEmpty =>
      lettersLearned == 0 &&
      wordsLearned == 0 &&
      secondsPlayed == 0 &&
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
  }) {
    return ChildProgress(
      lettersLearned: lettersLearned ?? this.lettersLearned,
      wordsLearned: wordsLearned ?? this.wordsLearned,
      secondsPlayed: secondsPlayed ?? this.secondsPlayed,
      strengths: strengths ?? this.strengths,
    );
  }

  Map<String, Object> toMap() => {
    'letters': lettersLearned,
    'words': wordsLearned,
    'seconds': secondsPlayed,
    for (final s in Skill.values) 'skill_${s.name}': strength(s),
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
    );
  }
}
