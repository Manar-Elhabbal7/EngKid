import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:engkids/app/theme.dart';
import 'package:engkids/features/home/screens/parents_screen.dart';
import 'package:engkids/features/profiles/data/profile_store.dart';
import 'package:engkids/features/profiles/models/profile.dart';
import 'package:engkids/features/profiles/providers/profiles_provider.dart';
import 'package:engkids/features/progress/data/progress_store.dart';
import 'package:engkids/features/progress/models/child_progress.dart';
import 'package:engkids/features/progress/providers/progress_provider.dart';

ProviderContainer _container() {
  final c = ProviderContainer(
    overrides: [
      profileStoreProvider.overrideWithValue(MemoryProfileStore()),
      progressStoreProvider.overrideWithValue(MemoryProgressStore()),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

Future<void> _pump(
  WidgetTester tester,
  ProviderContainer c, {
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    initialLocation: '/parents',
    routes: [
      GoRoute(path: '/parents', builder: (_, _) => const ParentsScreen()),
      GoRoute(path: '/profiles', builder: (_, _) => const Text('profiles')),
      GoRoute(path: '/home', builder: (_, _) => const SizedBox()),
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

Future<Profile> _sara(ProviderContainer c) async {
  final sara = await c
      .read(profilesProvider.notifier)
      .add(name: 'Sara', avatarId: 'witch');
  await c
      .read(progressProvider.notifier)
      .update(
        sara!.id,
        (p) => p.copyWith(
          lettersLearned: 26,
          wordsLearned: 18,
          secondsPlayed: 84 * 60,
          strengths: {Skill.alphabet: 0.8, Skill.spelling: 0.3},
        ),
      );
  await c.read(currentProfileIdProvider.notifier).select(sara.id);
  return sara;
}

void main() {
  group('ChildProgress', () {
    test('formats time played', () {
      expect(const ChildProgress().timePlayedLabel, '0m');
      expect(
        const ChildProgress(secondsPlayed: 12 * 60).timePlayedLabel,
        '12m',
      );
      expect(
        const ChildProgress(secondsPlayed: 84 * 60 + 30).timePlayedLabel,
        '1h 24m',
      );
    });

    test('bad saved values become zero instead of crashing', () {
      final p = ChildProgress.fromMap({
        'letters': -3,
        'words': 'lots',
        'skill_alphabet': 4.0,
      });
      expect(p.lettersLearned, 0);
      expect(p.wordsLearned, 0);
      expect(p.strength(Skill.alphabet), 1.0);
      expect(ChildProgress.fromMap('nonsense').isEmpty, isTrue);
    });

    test('round-trips through a map', () {
      const p = ChildProgress(
        lettersLearned: 5,
        wordsLearned: 7,
        secondsPlayed: 90,
        strengths: {Skill.matching: 0.5},
      );
      final back = ChildProgress.fromMap(p.toMap());
      expect(back.lettersLearned, 5);
      expect(back.wordsLearned, 7);
      expect(back.secondsPlayed, 90);
      expect(back.strength(Skill.matching), 0.5);
    });
  });

  group('current profile', () {
    test('is Boo when nobody is chosen', () {
      expect(_container().read(currentProfileProvider).id, Profile.booId);
    });

    test('falls back to Boo and drops progress when deleted', () async {
      final c = _container();
      final sara = await _sara(c);
      expect(c.read(currentProfileProvider).name, 'Sara');

      await c.read(profilesProvider.notifier).remove(sara.id);
      expect(c.read(currentProfileProvider).id, Profile.booId);
      expect(c.read(progressProvider).containsKey(sara.id), isFalse);
    });
  });

  group('chosen profile after a restart', () {
    // A "restart" = a fresh container reading the same saved store.
    ProviderContainer restart(ProfileStore store) {
      final c = ProviderContainer(
        overrides: [
          profileStoreProvider.overrideWithValue(store),
          progressStoreProvider.overrideWithValue(MemoryProgressStore()),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('keeps the chosen player', () async {
      final store = MemoryProfileStore();
      final c = restart(store);
      final n = c.read(profilesProvider.notifier);
      await n.add(name: 'Sara', avatarId: 'witch');
      final ali = await n.add(name: 'Ali', avatarId: 'vampire');
      await c.read(currentProfileIdProvider.notifier).select(ali!.id);

      expect(restart(store).read(currentProfileProvider).name, 'Ali');
    });

    test('uses the first saved player when nobody was chosen', () async {
      final store = MemoryProfileStore();
      await restart(store)
          .read(profilesProvider.notifier)
          .add(name: 'Sara', avatarId: 'witch');

      expect(restart(store).read(currentProfileProvider).name, 'Sara');
    });

    test(
      'falls back to the other player if the chosen one was deleted',
      () async {
        final store = MemoryProfileStore();
        final c = restart(store);
        final n = c.read(profilesProvider.notifier);
        final sara = await n.add(name: 'Sara', avatarId: 'witch');
        await n.add(name: 'Ali', avatarId: 'vampire');
        await c.read(currentProfileIdProvider.notifier).select(sara!.id);
        await n.remove(sara.id);

        expect(c.read(currentProfileProvider).name, 'Ali');
        expect(restart(store).read(currentProfileProvider).name, 'Ali');
      },
    );
  });

  group('ParentsScreen', () {
    testWidgets('shows Boo with empty progress when nobody is chosen', (
      tester,
    ) async {
      await _pump(tester, _container());
      expect(find.text('Boo'), findsOneWidget);
      expect(find.bySemanticsLabel('Letters Learned: 0'), findsOneWidget);
      expect(find.bySemanticsLabel('Time Played: 0m'), findsOneWidget);
      expect(find.byTooltip('Rename Boo'), findsNothing);
      expect(
        find.text("Boo's progress will show here after playing."),
        findsOneWidget,
      );
    });

    testWidgets('shows the chosen player and their progress', (tester) async {
      final c = _container();
      await _sara(c);
      await _pump(tester, c);
      expect(find.text('Sara'), findsOneWidget);
      expect(find.bySemanticsLabel('Letters Learned: 26'), findsOneWidget);
      expect(find.bySemanticsLabel('Words Learned: 18'), findsOneWidget);
      expect(find.bySemanticsLabel('Time Played: 1h 24m'), findsOneWidget);
      expect(find.text('Activity Strengths'), findsOneWidget);
    });

    testWidgets('pencil renames the player', (tester) async {
      final c = _container();
      await _sara(c);
      await _pump(tester, c);

      await tester.tap(find.byTooltip('Rename Sara'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(find.byType(TextField), 'Sarah');
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Sarah'), findsOneWidget);
      expect(c.read(currentProfileProvider).name, 'Sarah');
    });

    testWidgets('Sound toggles mute; Manage Profiles opens profiles', (
      tester,
    ) async {
      await _pump(tester, _container());
      expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
      await tester.tap(find.text('Sound'));
      await tester.pump();
      expect(find.byIcon(Icons.volume_off_rounded), findsOneWidget);

      await tester.tap(find.text('Manage Profiles'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('profiles'), findsOneWidget);
    });

    testWidgets('Sound and Manage Profiles fit a small phone', (tester) async {
      await _pump(tester, _container(), size: const Size(320, 640));
      expect(tester.takeException(), isNull);
      expect(find.text('Manage Profiles'), findsOneWidget);
      expect(find.text('Sound'), findsOneWidget);
    });

    testWidgets('fits a landscape phone without overflow', (tester) async {
      final c = _container();
      await _sara(c);
      await _pump(tester, c, size: const Size(844, 390));
      expect(tester.takeException(), isNull);
      expect(find.text('Sara'), findsOneWidget);
    });
  });
}
