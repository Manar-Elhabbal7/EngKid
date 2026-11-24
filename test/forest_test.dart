import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:engkids/app/theme.dart';
import 'package:engkids/features/forest/models/forest.dart';
import 'package:engkids/features/forest/models/forest_progress.dart';
import 'package:engkids/features/forest/screens/forest_screen.dart';
import 'package:engkids/features/lessons/models/lesson.dart';
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
  group('Forest rules', () {
    test('20 different words, 5 coins each, 20 bonus', () {
      expect(Forest.words.length, 20);
      expect(Forest.words.map((w) => w.key).toSet().length, 20);
      expect(Forest.coinsPerWord, 5);
      expect(Forest.finishBonus, 20);
    });

    test('first hear gives coins, words learned and vocabulary', () {
      final (once, earned) = ChildProgress.empty.withWordHeard(_w('Owl'));
      expect(earned, 5);
      expect(once.coins, 5);
      expect(once.wordsLearned, 1);
      expect(once.strength(Skill.vocabulary), closeTo(1 / 20, 1e-9));

      final (twice, again) = once.withWordHeard(_w('Owl'));
      expect(again, 0);
      expect(twice.coins, 5);
    });

    test('finishing needs every word, pays once, opens Word Matching', () {
      var p = ChildProgress.empty;
      for (final w in Forest.words.take(19)) {
        p = p.withWordHeard(w).$1;
      }
      expect(p.withForestFinished().$2, 0);
      p = p.withWordHeard(Forest.words.last).$1;
      final (done, bonus) = p.withForestFinished();
      expect(bonus, 20);
      expect(done.coins, 20 * 5 + 20);
      expect(Lesson.matching.isUnlocked(done.completedLessons), isTrue);
      expect(done.withForestFinished().$2, 0);
    });

    test('heard words are saved', () {
      final back = ChildProgress.fromMap(
        const ChildProgress(heardWords: {'owl'}).toMap(),
      );
      expect(back.heardWords, {'owl'});
    });
  });

  group('ForestScreen', () {
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
        initialLocation: '/play/forest',
        routes: [
          GoRoute(path: '/play', builder: (_, _) => const Text('games')),
          GoRoute(
            path: '/play/forest',
            builder: (_, _) => const ForestScreen(),
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

    Finder card(String word) =>
        find.bySemanticsLabel('Picture of $word. Tap to hear it.');

    Future<void> hear(WidgetTester tester, String word) async {
      await tester.tap(card(word));
      await tester.pump();
      voice.finish();
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

    testWidgets('same look as Alphabet: sign, coins, Boo, card, counter', (
      tester,
    ) async {
      await pump(tester);
      expect(find.text('Haunted Forest'), findsOneWidget);
      expect(find.bySemanticsLabel('0 coins'), findsOneWidget);
      expect(find.bySemanticsLabel('Boo the ghost'), findsOneWidget);
      expect(find.text('What is this? Tap the card!'), findsOneWidget);
      expect(card('Moon'), findsOneWidget);
      expect(find.text('1 / 20'), findsOneWidget);
      expect(find.text('Moon'), findsNothing, reason: 'word hidden until tap');
    });

    testWidgets('tapping says the word, shows it, coins after it finishes', (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(card('Moon'));
      await tester.pump();
      expect(voice.said, ['Moon']);
      expect(progress().coins, 0);

      voice.finish();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Moon'), findsOneWidget);
      expect(progress().coins, 5);
      expect(progress().wordsLearned, 1);
      expect(find.text('+5'), findsOneWidget);

      await hear(tester, 'Moon');
      expect(progress().coins, 5, reason: 'replaying gives nothing');
    });

    testWidgets('Next waits for the word to be heard', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Next'), warnIfMissed: false);
      await tester.pump();
      expect(card('Moon'), findsOneWidget);

      await hear(tester, 'Moon');
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(card('Star'), findsOneWidget);
      expect(find.text('2 / 20'), findsOneWidget);
    });

    testWidgets('background music is off while learning', (tester) async {
      await pump(tester);
      final audio = c.read(audioServiceProvider);
      expect(audio.themePaused, isTrue);
      expect(audio.muted, isFalse);
    });

    testWidgets('all words: bonus, Word Matching opens, back to games', (
      tester,
    ) async {
      await pump(tester);
      for (final w in Forest.words) {
        await hear(tester, w.word);
        await tester.tap(find.text(w == Forest.words.last ? 'Finish' : 'Next'));
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('You learned all 20 forest words!'), findsOneWidget);
      expect(find.text('+20 bonus coins'), findsOneWidget);
      expect(find.text('🧩 Word Matching is now open!'), findsOneWidget);
      expect(progress().coins, 120);
      expect(progress().strength(Skill.vocabulary), 1.0);

      await tester.tap(find.text('Back to games'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('games'), findsOneWidget);
    });

    testWidgets('fits a landscape phone', (tester) async {
      await pump(tester, size: const Size(844, 390));
      expect(tester.takeException(), isNull);
      expect(card('Moon'), findsOneWidget);
    });
  });
}
