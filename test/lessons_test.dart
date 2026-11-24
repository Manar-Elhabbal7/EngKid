import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:engkids/app/theme.dart';
import 'package:engkids/features/home/screens/play_picker_screen.dart';
import 'package:engkids/features/lessons/models/lesson.dart';
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

Future<void> _pump(WidgetTester tester, ProviderContainer c) async {
  final router = GoRouter(
    initialLocation: '/play',
    routes: [
      GoRoute(path: '/play', builder: (_, _) => const PlayPickerScreen()),
      GoRoute(path: '/play/alphabet', builder: (_, _) => const Text('abc')),
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

void main() {
  group('Lesson unlocking', () {
    test('only the alphabet is open at the start', () {
      expect(Lesson.values.where((l) => l.isUnlocked(const {})), [
        Lesson.alphabet,
      ]);
    });

    test('finishing a lesson opens only the next one', () {
      final open = Lesson.values.where((l) => l.isUnlocked({'alphabet'}));
      expect(open, [Lesson.alphabet, Lesson.forest]);
    });

    test('each lesson points at the one before it', () {
      expect(Lesson.alphabet.previous, isNull);
      expect(Lesson.matching.previous, Lesson.forest);
    });

    test('finished lessons are saved and loaded back', () {
      const p = ChildProgress(completedLessons: {'alphabet'});
      final back = ChildProgress.fromMap(p.toMap());
      expect(back.completedLessons, {'alphabet'});
      expect(
        ChildProgress.fromMap({
          'completed': ['alphabet', 7, null],
        }).completedLessons,
        {'alphabet'},
      );
    });
  });

  group('PlayPickerScreen', () {
    testWidgets('Alphabet is open and the others are locked', (tester) async {
      await _pump(tester, _container());
      expect(find.bySemanticsLabel('Alphabet Adventure, open'), findsOneWidget);
      for (final l in Lesson.values.skip(1)) {
        expect(find.bySemanticsLabel('${l.title}, locked'), findsOneWidget);
      }
    });

    testWidgets('tapping a locked lesson says what to finish first', (
      tester,
    ) async {
      await _pump(tester, _container());
      await tester.tap(find.text('Word Matching'));
      await tester.pump();
      expect(find.text('Finish Haunted Forest first!'), findsOneWidget);
    });

    testWidgets('tapping Alphabet opens it', (tester) async {
      await _pump(tester, _container());
      await tester.tap(find.text('Alphabet Adventure'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('abc'), findsOneWidget);
    });

    testWidgets('finishing Alphabet opens Haunted Forest', (tester) async {
      final c = _container();
      await c
          .read(progressProvider.notifier)
          .markCompleted(Profile.booId, Lesson.alphabet.name);
      await _pump(tester, c);
      expect(find.bySemanticsLabel('Haunted Forest, open'), findsOneWidget);
      expect(find.bySemanticsLabel('Word Matching, locked'), findsOneWidget);
    });

    testWidgets('each profile has its own unlocked lessons', (tester) async {
      final c = _container();
      final n = c.read(profilesProvider.notifier);
      final sara = await n.add(name: 'Sara', avatarId: 'witch');
      final ali = await n.add(name: 'Ali', avatarId: 'vampire');
      await c
          .read(progressProvider.notifier)
          .markCompleted(sara!.id, Lesson.alphabet.name);
      await c.read(currentProfileIdProvider.notifier).select(ali!.id);

      await _pump(tester, c);
      expect(find.bySemanticsLabel('Haunted Forest, locked'), findsOneWidget);
    });
  });
}
