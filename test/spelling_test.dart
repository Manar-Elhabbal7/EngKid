import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:engkids/app/theme.dart';
import 'package:engkids/features/forest/models/forest.dart';
import 'package:engkids/features/lessons/models/lesson.dart';
import 'package:engkids/features/profiles/data/profile_store.dart';
import 'package:engkids/features/profiles/models/profile.dart';
import 'package:engkids/features/profiles/providers/profiles_provider.dart';
import 'package:engkids/features/progress/data/progress_store.dart';
import 'package:engkids/features/progress/models/child_progress.dart';
import 'package:engkids/features/progress/providers/progress_provider.dart';
import 'package:engkids/features/spelling/models/spelling.dart';
import 'package:engkids/features/spelling/models/spelling_progress.dart';
import 'package:engkids/features/spelling/screens/spelling_screen.dart';
import 'package:engkids/shared/audio/audio_service.dart';
import 'package:engkids/shared/audio/letter_voice.dart';

import 'helpers/fake_voice.dart';

ForestWord _w(String s) => Forest.words.firstWhere((w) => w.word == s);

void main() {
  group('Spelling rules', () {
    test('10 short known forest words, all different', () {
      expect(Spelling.words.length, 10);
      expect(Spelling.words.toSet().length, 10);
      expect(Spelling.words.every((w) => w.word.length <= 4), isTrue);
      expect(Spelling.words.every(Forest.words.contains), isTrue);
    });

    test('first spelling gives coins and the Spelling strength', () {
      final (once, earned) = ChildProgress.empty.withWordSpelled(_w('Owl'));
      expect(earned, 5);
      expect(once.coins, 5);
      expect(once.strength(Skill.spelling), closeTo(1 / 10, 1e-9));
      expect(once.withWordSpelled(_w('Owl')).$2, 0);
    });

    test('finishing needs every word, pays once, opens Magic Cauldron', () {
      var p = ChildProgress.empty;
      for (final w in Spelling.words.take(9)) {
        p = p.withWordSpelled(w).$1;
      }
      expect(p.withSpellingFinished().$2, 0);
      p = p.withWordSpelled(Spelling.words.last).$1;
      final (done, bonus) = p.withSpellingFinished();
      expect(bonus, 20);
      expect(done.coins, 10 * 5 + 20);
      expect(Lesson.cauldron.isUnlocked(done.completedLessons), isTrue);
      expect(done.withSpellingFinished().$2, 0);
    });

    test('resumes at the first word not spelled yet', () {
      final p = ChildProgress.empty.withWordSpelled(Spelling.words.first).$1;
      expect(p.spellingResumeIndex, 1);
    });

    test('spelled words are saved', () {
      final back = ChildProgress.fromMap(
        const ChildProgress(spelledWords: {'owl'}).toMap(),
      );
      expect(back.spelledWords, {'owl'});
    });
  });

  group('SpellingScreen', () {
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
        initialLocation: '/play/quiz',
        routes: [
          GoRoute(path: '/play', builder: (_, _) => const Text('games')),
          GoRoute(
            path: '/play/quiz',
            builder: (_, _) => const SpellingScreen(),
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

    Finder letter(String l) => find.bySemanticsLabel('Letter $l');

    Future<void> tapLetter(WidgetTester tester, String l) async {
      await tester.tap(letter(l).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    Future<void> spell(WidgetTester tester, ForestWord w) async {
      for (final l in w.word.toUpperCase().split('')) {
        await tapLetter(tester, l);
      }
      await tester.pump(const Duration(milliseconds: 300));
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

    testWidgets('same look as the other lessons: picture, slots, letters', (
      tester,
    ) async {
      await pump(tester);
      expect(find.text('Spell-It Quiz'), findsOneWidget);
      expect(find.bySemanticsLabel('0 coins'), findsOneWidget);
      expect(find.bySemanticsLabel('Boo the ghost'), findsOneWidget);
      expect(find.text('Spell the word! Tap the letters.'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Picture of Owl. Tap to hear it.'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Spelled so far: _ _ _'), findsOneWidget);
      for (final l in ['O', 'W', 'L']) {
        expect(letter(l), findsOneWidget);
      }
      expect(find.text('1 / 10'), findsOneWidget);
    });

    testWidgets('tapping the picture says the word', (tester) async {
      await pump(tester);
      await tester.tap(
        find.bySemanticsLabel('Picture of Owl. Tap to hear it.'),
      );
      await tester.pump();
      expect(voice.said, ['Owl']);
    });

    testWidgets('letters in order spell the word and give 5 coins once', (
      tester,
    ) async {
      await pump(tester);
      await tapLetter(tester, 'O');
      expect(find.bySemanticsLabel('Spelled so far: O _ _'), findsOneWidget);
      expect(find.text('Keep going!'), findsOneWidget);

      await tapLetter(tester, 'W');
      await tapLetter(tester, 'L');
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.bySemanticsLabel('Spelled so far: O W L'), findsOneWidget);
      expect(progress().coins, 5);
      expect(find.text('+5'), findsOneWidget);
      expect(voice.said, ['Owl'], reason: 'the finished word is said');
      expect(find.text('Great spelling! Tap Next!'), findsOneWidget);
    });

    testWidgets('a wrong letter shakes; after 2 the right one glows', (
      tester,
    ) async {
      await pump(tester);
      await tapLetter(tester, 'L');
      expect(find.text('Oops! Try another letter!'), findsOneWidget);
      expect(find.bySemanticsLabel('Spelled so far: _ _ _'), findsOneWidget);

      await tapLetter(tester, 'W');
      expect(find.text('Look for the glowing pumpkin!'), findsOneWidget);
      expect(progress().coins, 0);
    });

    testWidgets('repeated letters work (MOON)', (tester) async {
      await c
          .read(progressProvider.notifier)
          .update(
            Profile.booId,
            (p) => p.copyWith(
              spelledWords: {for (final w in Spelling.words.take(4)) w.key},
            ),
          );
      await pump(tester);
      expect(
        find.bySemanticsLabel('Picture of Moon. Tap to hear it.'),
        findsOneWidget,
      );
      await spell(tester, _w('Moon'));
      expect(find.bySemanticsLabel('Spelled so far: M O O N'), findsOneWidget);
    });

    testWidgets('Next waits for the word, then moves on', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Next'), warnIfMissed: false);
      await tester.pump();
      expect(find.text('1 / 10'), findsOneWidget);

      await spell(tester, _w('Owl'));
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(find.text('2 / 10'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Picture of Bat. Tap to hear it.'),
        findsOneWidget,
      );
    });

    testWidgets('background music is off while spelling', (tester) async {
      await pump(tester);
      final audio = c.read(audioServiceProvider);
      expect(audio.themePaused, isTrue);
      expect(audio.muted, isFalse);
    });

    testWidgets('all words: bonus, Magic Cauldron opens, back to games', (
      tester,
    ) async {
      await pump(tester);
      for (final w in Spelling.words) {
        await spell(tester, w);
        await tester.tap(
          find.text(w == Spelling.words.last ? 'Finish' : 'Next'),
        );
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('You spelled all 10 words!'), findsOneWidget);
      expect(find.text('+20 bonus coins'), findsOneWidget);
      expect(find.text('🫧 Magic Cauldron is now open!'), findsOneWidget);
      expect(progress().coins, 70);
      expect(progress().strength(Skill.spelling), 1.0);

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
      expect(letter('O'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });
  });
}
