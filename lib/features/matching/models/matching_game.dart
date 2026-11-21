import 'dart:math';
import '../../vocabulary/models/vocab_data.dart';

/// One emoji↔word pair used in a matching round.
class MatchPair {
  const MatchPair({required this.word, required this.emoji, required this.id});

  /// Stable id = word string (unique across the vocab pool).
  final String id;
  final String word;
  final String emoji;
}

/// Result of attempting to match an emoji tile to a word slot.
enum MatchResult { correct, wrong, alreadyMatched }

/// State of one matching round (5 pairs).
class MatchingRound {
  MatchingRound({required this.pairs}) : _matched = {};

  final List<MatchPair> pairs;

  /// ids of correctly matched pairs this round.
  final Set<String> _matched;

  Set<String> get matched => Set.unmodifiable(_matched);

  bool get isComplete => _matched.length == pairs.length;

  MatchResult attempt({required String emojiId, required String wordId}) {
    if (_matched.contains(emojiId)) return MatchResult.alreadyMatched;
    if (emojiId == wordId) {
      _matched.add(emojiId);
      return MatchResult.correct;
    }
    return MatchResult.wrong;
  }
}

/// Builds rounds by sampling randomly from [VocabData.allWords].
class MatchingGameFactory {
  MatchingGameFactory({int? seed}) : _rng = Random(seed);

  final Random _rng;

  static const int pairsPerRound = 5;
  static const int totalRounds = 3;

  /// Returns [totalRounds] non-overlapping rounds, each with [pairsPerRound] pairs.
  List<MatchingRound> buildRounds() {
    // Deduplicate by word (some words like "Bat" appear in multiple categories).
    final seen = <String>{};
    final pool = VocabData.allWords
        .where((w) => seen.add(w.word))
        .toList()
      ..shuffle(_rng);
    final rounds = <MatchingRound>[];
    var offset = 0;
    for (var r = 0; r < totalRounds; r++) {
      final slice = pool.sublist(offset, offset + pairsPerRound);
      offset += pairsPerRound;
      rounds.add(MatchingRound(
        pairs: slice
            .map((w) => MatchPair(id: w.word, word: w.word, emoji: w.emoji))
            .toList(),
      ));
    }
    return rounds;
  }
}
