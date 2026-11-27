import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:engkids/app/theme.dart';
import 'package:engkids/features/alphabet/models/alphabet.dart';
import 'package:engkids/features/alphabet/models/alphabet_progress.dart';
import 'package:engkids/features/alphabet/screens/alphabet_screen.dart';
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

AlphabetLetter _l(String s) =>
    Alphabet.letters.firstWhere((l) => l.letter == s);

void main() {
  group('Alphabet rules', () {
    test('26 letters, 5 coins each, 20 bonus', () {
      expect(Alphabet.letters.length, 26);
      expect(
        Alphabet.letters.map((l) => l.letter).join(),
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
      );
      expect(Alphabet.coinsPerLetter, 5);
      expect(Alphabet.finishBonus, 20);
    });

    test('first hear gives coins and progress; repeats give nothing', () {
      final (once, earned) = ChildProgress.empty.withLetterHeard(_l('A'));
      expect(earned, 5);
      expect(once.coins, 5);
      expect(once.lettersLearned, 1);
      expect(once.strength(Skill.alphabet), closeTo(1 / 26, 1e-9));

      final (twice, again) = once.withLetterHeard(_l('A'));
      expect(again, 0);
      expect(twice.coins, 5);
      expect(twice.lettersLearned, 1);
    });

    test('finishing needs all 26 and only pays once', () {
      var p = ChildProgress.empty;
      for (final l in Alphabet.letters.take(25)) {
        p = p.withLetterHeard(l).$1;
      }
      expect(p.withAlphabetFinished().$2, 0);

      p = p.withLetterHeard(_l('Z')).$1;
      final (done, bonus) = p.withAlphabetFinished();
      expect(bonus, 20);
      expect(done.coins, 26 * 5 + 20);
      expect(done.completedLessons, contains(Lesson.alphabet.name));
      expect(Lesson.forest.isUnlocked(done.completedLessons), isTrue);
      expect(done.withAlphabetFinished().$2, 0);
    });

    test('resumes at the first letter not heard yet', () {
      final p = ChildProgress(heardLetters: {'a', 'b'});
      expect(Alphabet.letters[p.alphabetResumeIndex].letter, 'C');
    });

    test('coins and heard letters are saved', () {
      final p = ChildProgress.fromMap(
        const ChildProgress(coins: 15, heardLetters: {'a'}).toMap(),
      );
      expect(p.coins, 15);
      expect(p.heardLetters, {'a'});
    });

    test('play time adds up', () async {
      final c = ProviderContainer(
        overrides: [
          progressStoreProvider.overrideWithValue(MemoryProgressStore()),
        ],
      );
      addTearDown(c.dispose);
      final n = c.read(progressProvider.notifier);
      await n.addPlayTime('x', const Duration(seconds: 90));
      await n.addPlayTime('x', const Duration(seconds: 30));
      expect(n.of('x').secondsPlayed, 120);
    });
  });

  group('AlphabetScreen', () {
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
        initialLocation: '/play/alphabet',
        routes: [
          GoRoute(path: '/play', builder: (_, _) => const Text('games')),
          GoRoute(
            path: '/play/alphabet',
            builder: (_, _) => const AlphabetScreen(),
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

    Finder pumpkin(String letter) =>
        find.bySemanticsLabel('Letter $letter. Tap to hear it.');

    Future<void> hearCurrent(WidgetTester tester, String letter) async {
      await tester.tap(pumpkin(letter));
      await tester.pump();
      voice.finish();
      await tester.pump();
      await tester.pump();
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

    testWidgets('looks like the mockup: sign, Boo, bubble, pumpkin, coins', (
      tester,
    ) async {
      await pump(tester);
      expect(find.text('Alphabet Adventure'), findsOneWidget);
      expect(find.bySemanticsLabel('Boo the ghost'), findsOneWidget);
      expect(find.text('Tap the pumpkin to hear the letter!'), findsOneWidget);
      expect(pumpkin('A'), findsOneWidget);
      expect(find.bySemanticsLabel('0 coins'), findsOneWidget);
      expect(find.text('1 / 26'), findsOneWidget);
    });

    testWidgets('coins come after the letter finishes, only the first time', (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(pumpkin('A'));
      await tester.pump();
      expect(voice.said, ['A']);
      expect(find.text('Listen carefully!'), findsOneWidget);
      expect(progress().coins, 0, reason: 'not finished hearing yet');

      voice.finish();
      await tester.pump();
      await tester.pump();
      expect(progress().coins, 5);
      expect(progress().lettersLearned, 1);
      expect(find.text('+5'), findsOneWidget);

      await hearCurrent(tester, 'A');
      expect(progress().coins, 5, reason: 'replaying gives nothing');
    });

    testWidgets('Next is locked until the letter is heard', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Next'), warnIfMissed: false);
      await tester.pump();
      expect(pumpkin('A'), findsOneWidget);

      await hearCurrent(tester, 'A');
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(pumpkin('B'), findsOneWidget);
      expect(find.text('2 / 26'), findsOneWidget);
    });

    testWidgets('muted: no sound, no coins, Boo asks to turn sound on', (
      tester,
    ) async {
      // Not awaited: tests have no audio device, so the player never answers.
      c.read(audioServiceProvider).toggleMute();
      await pump(tester);
      await tester.tap(pumpkin('A'));
      await tester.pump();
      expect(voice.said, isEmpty);
      expect(find.text('Turn on the sound to hear me!'), findsOneWidget);
      expect(progress().coins, 0);
    });

    testWidgets('background music is off while learning, back after', (
      tester,
    ) async {
      await pump(tester);
      final audio = c.read(audioServiceProvider);
      expect(audio.themePaused, isTrue);
      expect(audio.muted, isFalse, reason: 'music off without muting');

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pump();
      // The alphabet page is removed once the page transition finishes.
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('games'), findsOneWidget);
      expect(audio.themePaused, isFalse);
    });

    testWidgets('picks up where the child stopped', (tester) async {
      await c
          .read(progressProvider.notifier)
          .update(Profile.booId, (p) => p.copyWith(heardLetters: {'a', 'b'}));
      await pump(tester);
      expect(pumpkin('C'), findsOneWidget);
    });

    testWidgets('all 26 letters: bonus, Haunted Forest opens, back to games', (
      tester,
    ) async {
      await pump(tester);
      for (final l in Alphabet.letters) {
        await hearCurrent(tester, l.letter);
        await tester.tap(find.text(l.letter == 'Z' ? 'Finish' : 'Next'));
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('You learned all 26 letters!'), findsOneWidget);
      expect(find.text('+20 bonus coins'), findsOneWidget);
      expect(find.text('👻 Haunted Forest is now open!'), findsOneWidget);
      expect(progress().coins, 150);
      expect(progress().lettersLearned, 26);
      expect(progress().strength(Skill.alphabet), 1.0);
      expect(progress().completedLessons, contains('alphabet'));

      await tester.tap(find.text('Back to games'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('games'), findsOneWidget);
    });

    testWidgets('progress is saved for the chosen profile', (tester) async {
      final sara = await c
          .read(profilesProvider.notifier)
          .add(name: 'Sara', avatarId: 'witch');
      await c.read(currentProfileIdProvider.notifier).select(sara!.id);
      await pump(tester);
      await hearCurrent(tester, 'A');
      expect(c.read(progressProvider.notifier).of(sara.id).coins, 5);
      expect(progress().coins, 0, reason: "Boo's progress is separate");
    });

    testWidgets('Prev goes back a letter; Next stays open for heard ones', (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(find.bySemanticsLabel('Previous'), warnIfMissed: false);
      await tester.pump();
      expect(pumpkin('A'), findsOneWidget, reason: 'Prev is off on A');

      await hearCurrent(tester, 'A');
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Previous'));
      await tester.pump();
      expect(pumpkin('A'), findsOneWidget);
      expect(find.text('1 / 26'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(pumpkin('B'), findsOneWidget, reason: 'A was heard before');
    });

    testWidgets('fits a landscape phone', (tester) async {
      await pump(tester, size: const Size(844, 390));
      expect(tester.takeException(), isNull);
      expect(pumpkin('A'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });
  });
}
