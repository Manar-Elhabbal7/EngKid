import 'package:flutter/material.dart';

import 'dart:ui' show CheckedState;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:engkids/app/theme.dart';
import 'package:engkids/features/forest/models/forest.dart';
import 'package:engkids/features/lessons/models/lesson.dart';
import 'package:engkids/features/matching/models/matching.dart';
import 'package:engkids/features/matching/models/matching_progress.dart';
import 'package:engkids/features/matching/screens/matching_screen.dart';
import 'package:engkids/features/profiles/data/profile_store.dart';
import 'package:engkids/features/profiles/models/profile.dart';
import 'package:engkids/features/profiles/providers/profiles_provider.dart';
import 'package:engkids/features/progress/data/progress_store.dart';
import 'package:engkids/features/progress/models/child_progress.dart';
import 'package:engkids/features/progress/providers/progress_provider.dart';
import 'package:engkids/shared/audio/audio_service.dart';
import 'package:engkids/shared/audio/letter_voice.dart';

import 'helpers/fake_voice.dart';

ForestWord _w(String s) => Forest.words.firstWhere((w) => w.word == s);

void main() {
  group('Matching rules', () {
    test('5 rounds of 4 covering every forest word once', () {
      expect(Matching.rounds.length, 5);
      expect(Matching.rounds.every((r) => r.length == 4), isTrue);
      expect(Matching.rounds.expand((r) => r).toList(), Forest.words);
    });

    test('first match gives coins and the Matching strength', () {
      final (once, earned) = ChildProgress.empty.withPairMatched(_w('Owl'));
      expect(earned, 5);
      expect(once.coins, 5);
      expect(once.strength(Skill.matching), closeTo(1 / 20, 1e-9));
      final (_, again) = once.withPairMatched(_w('Owl'));
      expect(again, 0);
    });

    test('finishing needs every pair, pays once, opens Spell-It Quiz', () {
      var p = ChildProgress.empty;
      for (final w in Forest.words.take(19)) {
        p = p.withPairMatched(w).$1;
      }
      expect(p.withMatchingFinished().$2, 0);
      p = p.withPairMatched(Forest.words.last).$1;
      final (done, bonus) = p.withMatchingFinished();
      expect(bonus, 20);
      expect(done.coins, 20 * 5 + 20);
      expect(Lesson.quiz.isUnlocked(done.completedLessons), isTrue);
      expect(done.withMatchingFinished().$2, 0);
    });

    test('resumes at the first round with an unmatched pair', () {
      var p = ChildProgress.empty;
      for (final w in Matching.rounds[0]) {
        p = p.withPairMatched(w).$1;
      }
      expect(p.matchingResumeRound, 1);
    });

    test('matched pairs are saved', () {
      final back = ChildProgress.fromMap(
        const ChildProgress(matchedWords: {'owl'}).toMap(),
      );
      expect(back.matchedWords, {'owl'});
    });
  });

  group('MatchingScreen', () {
    late FakeVoice voice;
    late ProviderContainer c;

    Future<void> pump(
      WidgetTester tester, {
      Size size = const Size(390, 844),
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final router = GoRouter(
        initialLocation: '/play/matching',
        routes: [
          GoRoute(path: '/play', builder: (_, _) => const Text('games')),
          GoRoute(
            path: '/play/matching',
            builder: (_, _) => const MatchingScreen(),
          ),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: MaterialApp.router(
            theme: HalloweenTheme.theme,
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();
    }

    Finder picture(String w) => find.bySemanticsLabel('Picture: $w');
    Finder word(String w) => find.bySemanticsLabel('Word: $w');

    Future<void> match(WidgetTester tester, String a, String b) async {
      await tester.tap(picture(a));
      await tester.pump();
      await tester.tap(word(b));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    ChildProgress progress() =>
        c.read(progressProvider.notifier).of(Profile.booId);

    setUp(() {
      voice = FakeVoice();
      c = ProviderContainer(
        overrides: [
          profileStoreProvider.overrideWithValue(MemoryProfileStore()),
          progressStoreProvider.overrideWithValue(MemoryProgressStore()),
          letterVoiceProvider.overrideWithValue(voice),
        ],
      );
      addTearDown(c.dispose);
    });

    testWidgets('same look as the other lessons, with 4 pictures and words', (
      tester,
    ) async {
      await pump(tester);
      expect(find.text('Word Matching'), findsOneWidget);
      expect(find.bySemanticsLabel('0 coins'), findsOneWidget);
      expect(find.bySemanticsLabel('Boo the ghost'), findsOneWidget);
      expect(find.text('Match each picture to its word!'), findsOneWidget);
      expect(find.text('Round 1 / 5'), findsOneWidget);
      for (final w in Matching.rounds[0]) {
        expect(picture(w.word), findsOneWidget);
        expect(word(w.word), findsOneWidget);
      }
    });

    testWidgets('a correct pair turns green and gives 5 coins once', (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(picture('Moon'));
      await tester.pump();
      expect(find.text('Now tap its word!'), findsOneWidget);

      await tester.tap(word('Moon'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(progress().coins, 5);
      expect(find.text('+5'), findsOneWidget);
      expect(
        tester
            .getSemantics(picture('Moon'))
            .getSemanticsData()
            .flagsCollection
            .isChecked,
        CheckedState.isTrue,
      );
    });

    testWidgets('tapping a word says it', (tester) async {
      await pump(tester);
      await tester.tap(word('Tree'));
      await tester.pump();
      expect(voice.said, ['Tree']);
      expect(find.text('Now tap its picture!'), findsOneWidget);
    });

    testWidgets('a wrong pair shakes, gives nothing, Boo says try again', (
      tester,
    ) async {
      await pump(tester);
      await match(tester, 'Moon', 'Star');
      expect(find.text('Oops! Try again!'), findsOneWidget);
      expect(progress().coins, 0);
    });

    testWidgets('Next waits until all 4 are matched', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Next'), warnIfMissed: false);
      await tester.pump();
      expect(find.text('Round 1 / 5'), findsOneWidget);

      for (final w in Matching.rounds[0]) {
        await match(tester, w.word, w.word);
      }
      expect(find.text('Great job! Tap Next!'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(find.text('Round 2 / 5'), findsOneWidget);
      expect(picture('Owl'), findsOneWidget);
    });

    testWidgets('background music is off while matching', (tester) async {
      await pump(tester);
      final audio = c.read(audioServiceProvider);
      expect(audio.themePaused, isTrue);
      expect(audio.muted, isFalse);
    });

    testWidgets('all rounds: bonus, Spell-It Quiz opens, back to games', (
      tester,
    ) async {
      await pump(tester);
      for (var r = 0; r < Matching.rounds.length; r++) {
        for (final w in Matching.rounds[r]) {
          await match(tester, w.word, w.word);
        }
        final last = r == Matching.rounds.length - 1;
        await tester.tap(find.text(last ? 'Finish' : 'Next'));
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('You matched all 20 words!'), findsOneWidget);
      expect(find.text('+20 bonus coins'), findsOneWidget);
      expect(find.text('❓ Spell-It Quiz is now open!'), findsOneWidget);
      expect(progress().coins, 120);
      expect(progress().strength(Skill.matching), 1.0);

      await tester.tap(find.text('Back to games'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('games'), findsOneWidget);
    });

    testWidgets('fits phones in both orientations', (tester) async {
      await pump(tester, size: const Size(360, 640));
      expect(tester.takeException(), isNull);
      await pump(tester, size: const Size(844, 390));
      expect(tester.takeException(), isNull);
      expect(picture('Moon'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });
  });
}
