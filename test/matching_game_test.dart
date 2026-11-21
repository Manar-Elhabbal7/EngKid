import 'package:flutter_test/flutter_test.dart';
import 'package:engkids/features/matching/models/matching_game.dart';

void main() {
  group('MatchingGameFactory', () {
    test('builds correct number of rounds', () {
      final rounds = MatchingGameFactory(seed: 42).buildRounds();
      expect(rounds.length, MatchingGameFactory.totalRounds);
    });

    test('each round has correct number of pairs', () {
      final rounds = MatchingGameFactory(seed: 42).buildRounds();
      for (final round in rounds) {
        expect(round.pairs.length, MatchingGameFactory.pairsPerRound);
      }
    });

    test('no duplicate pair ids across all rounds', () {
      final rounds = MatchingGameFactory(seed: 42).buildRounds();
      final allIds = rounds.expand((r) => r.pairs.map((p) => p.id)).toList();
      expect(allIds.toSet().length, allIds.length);
    });
  });

  group('MatchingRound', () {
    late MatchingRound round;

    setUp(() {
      round = MatchingRound(pairs: [
        const MatchPair(id: 'Cat',  word: 'Cat',  emoji: '🐱'),
        const MatchPair(id: 'Dog',  word: 'Dog',  emoji: '🐶'),
        const MatchPair(id: 'Frog', word: 'Frog', emoji: '🐸'),
      ]);
    });

    test('correct attempt marks pair as matched', () {
      final result = round.attempt(emojiId: 'Cat', wordId: 'Cat');
      expect(result, MatchResult.correct);
      expect(round.matched, contains('Cat'));
    });

    test('wrong attempt returns wrong result and does not match', () {
      final result = round.attempt(emojiId: 'Cat', wordId: 'Dog');
      expect(result, MatchResult.wrong);
      expect(round.matched, isEmpty);
    });

    test('attempting an already matched pair returns alreadyMatched', () {
      round.attempt(emojiId: 'Cat', wordId: 'Cat');
      final result = round.attempt(emojiId: 'Cat', wordId: 'Cat');
      expect(result, MatchResult.alreadyMatched);
    });

    test('isComplete is true only when all pairs matched', () {
      expect(round.isComplete, isFalse);
      round.attempt(emojiId: 'Cat',  wordId: 'Cat');
      round.attempt(emojiId: 'Dog',  wordId: 'Dog');
      expect(round.isComplete, isFalse);
      round.attempt(emojiId: 'Frog', wordId: 'Frog');
      expect(round.isComplete, isTrue);
    });
  });
}
