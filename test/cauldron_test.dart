import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:engkids/app/theme.dart';
import 'package:engkids/features/cauldron/models/cauldron.dart';
import 'package:engkids/features/cauldron/models/cauldron_progress.dart';
import 'package:engkids/features/cauldron/screens/cauldron_screen.dart';
import 'package:engkids/features/forest/models/forest.dart';
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

void main() {
  group('Cauldron rules', () {
    test('10 different forest ingredients', () {
      expect(Cauldron.ingredients.length, 10);
      expect(Cauldron.ingredients.toSet().length, 10);
      expect(Cauldron.ingredients.every(Forest.words.contains), isTrue);
    });

    test('each round offers 3 different choices including the answer', () {
      final rng = math.Random(1);
      for (final target in Cauldron.ingredients) {
        final choices = Cauldron.choicesFor(target, rng);
        expect(choices.length, 3);
        expect(choices.toSet().length, 3);
        expect(choices, contains(target));
      }
    });

    test('a new ingredient gives 5 coins once', () {
      final bat = Cauldron.ingredients.first;
      final (once, earned) = ChildProgress.empty.withIngredientBrewed(bat);
      expect(earned, 5);
      expect(once.withIngredientBrewed(bat).$2, 0);
    });

    test('brewing needs every ingredient and pays once', () {
      var p = ChildProgress.empty;
      for (final w in Cauldron.ingredients.take(9)) {
        p = p.withIngredientBrewed(w).$1;
      }
      expect(p.withPotionBrewed().$2, 0);
      p = p.withIngredientBrewed(Cauldron.ingredients.last).$1;
      final (done, bonus) = p.withPotionBrewed();
      expect(bonus, 20);
      expect(done.coins, 70);
      expect(done.completedLessons, contains(Lesson.cauldron.name));
      expect(done.withPotionBrewed().$2, 0);
    });

    test('brewed ingredients are saved; resumes at the next one', () {
      final p = ChildProgress.fromMap(
        const ChildProgress(brewedWords: {'bat'}).toMap(),
      );
      expect(p.brewedWords, {'bat'});
      expect(p.cauldronResumeIndex, 1);
    });
  });

  group('CauldronScreen', () {
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
        initialLocation: '/play/cauldron',
        routes: [
          GoRoute(path: '/play', builder: (_, _) => const Text('games')),
          GoRoute(
            path: '/play/cauldron',
            builder: (_, _) => const CauldronScreen(),
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
      await tester.pump();
    }

    Finder orb(String w) => find.bySemanticsLabel('Ingredient: $w');

    /// A wrong choice that's on screen this round.
    ForestWord distractor(WidgetTester tester, ForestWord target) =>
        Forest.words.firstWhere((w) => w != target && tester.any(orb(w.word)));

    Future<void> pick(WidgetTester tester, String w) async {
      await tester.tap(orb(w));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
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

    testWidgets('same look as the other lessons, with the cauldron', (
      tester,
    ) async {
      await pump(tester);
      expect(find.text('Magic Cauldron'), findsOneWidget);
      expect(find.bySemanticsLabel('0 coins'), findsOneWidget);
      expect(find.bySemanticsLabel('Boo the ghost'), findsOneWidget);
      expect(find.bySemanticsLabel('Magic cauldron'), findsOneWidget);
      expect(find.text('Tap Hear it! What does Boo need?'), findsOneWidget);
      expect(orb('Bat'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(r'^Ingredient: ')), findsNWidgets(3));
      expect(find.text('1 / 10'), findsOneWidget);
    });

    testWidgets('nothing plays by itself; Hear it says the ingredient', (
      tester,
    ) async {
      await pump(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(voice.said, isEmpty, reason: 'no sound when the screen opens');

      await tester.tap(find.bySemanticsLabel('Hear it again'));
      await tester.pump();
      expect(voice.said, ['Bat']);
      expect(find.text('Put the Bat in the cauldron!'), findsOneWidget);
    });

    testWidgets('a wrong pick shakes and Boo names it; no coins', (
      tester,
    ) async {
      await pump(tester);
      final wrong = distractor(tester, Cauldron.ingredients.first);
      await pick(tester, wrong.word);
      expect(
        find.text("Oops! That's the ${wrong.word}. Try again!"),
        findsOneWidget,
      );
      expect(voice.said.last, wrong.word);
      expect(progress().coins, 0);
    });

    testWidgets('the right pick drops in and gives 5 coins once', (
      tester,
    ) async {
      await pump(tester);
      await pick(tester, 'Bat');
      expect(progress().coins, 5);
      expect(find.text('+5'), findsOneWidget);
      expect(find.text('Splash! Tap Next!'), findsOneWidget);
      expect(orb('Bat'), findsNothing, reason: 'it fell into the pot');
    });

    testWidgets('Next waits for the right pick, then says the next one', (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(find.text('Next'), warnIfMissed: false);
      await tester.pump();
      expect(find.text('1 / 10'), findsOneWidget);

      await pick(tester, 'Bat');
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(find.text('2 / 10'), findsOneWidget);
      expect(find.text('Tap Hear it! What does Boo need?'), findsOneWidget);
      expect(voice.said, isNot(contains('Spider')));
    });

    testWidgets('muted: no voice, Boo still shows the word to find', (
      tester,
    ) async {
      c.read(audioServiceProvider).toggleMute();
      await pump(tester);
      await tester.tap(find.bySemanticsLabel('Hear it again'));
      await tester.pump();
      expect(voice.said, isEmpty);
      expect(find.text('Turn on the sound, or find the Bat!'), findsOneWidget);
    });

    testWidgets('background music is off while brewing', (tester) async {
      await pump(tester);
      final audio = c.read(audioServiceProvider);
      expect(audio.themePaused, isTrue);
      expect(audio.muted, isFalse);
    });

    testWidgets('all ingredients: bonus, last lesson done, back to games', (
      tester,
    ) async {
      await pump(tester);
      for (final w in Cauldron.ingredients) {
        await pick(tester, w.word);
        final last = w == Cauldron.ingredients.last;
        await tester.tap(find.text(last ? 'Finish' : 'Next'));
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('You brewed the magic potion!'), findsOneWidget);
      expect(find.text('+20 bonus coins'), findsOneWidget);
      expect(find.textContaining('is now open'), findsNothing);
      expect(progress().coins, 70);
      expect(progress().completedLessons, contains(Lesson.cauldron.name));

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
      expect(orb('Bat'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });
  });
}
