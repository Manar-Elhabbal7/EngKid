import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:engkids/app/theme.dart';
import 'package:engkids/features/profiles/data/profile_store.dart';
import 'package:engkids/features/profiles/models/profile.dart';
import 'package:engkids/features/profiles/providers/profiles_provider.dart';
import 'package:engkids/features/profiles/screens/profile_picker_screen.dart';

ProviderContainer _container(ProfileStore store) {
  final c = ProviderContainer(
    overrides: [profileStoreProvider.overrideWithValue(store)],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('ProfilesNotifier', () {
    test('starts with Boo as the default player', () {
      final profiles = _container(MemoryProfileStore()).read(profilesProvider);
      expect(profiles.single.name, 'Boo');
      expect(profiles.single.avatarId, 'boo');
    });

    test('first player replaces Boo; name is tidied and capped', () async {
      final c = _container(MemoryProfileStore());
      final p = await c
          .read(profilesProvider.notifier)
          .add(name: '  Mia   the  Great Witch ', avatarId: 'witch');
      expect(p!.name, 'Mia the Grea');
      expect(c.read(profilesProvider).map((p) => p.name), ['Mia the Grea']);
    });

    test(
      'rejects blank names; unknown costumes fall back to the witch',
      () async {
        final notifier = _container(MemoryProfileStore())
            .read(profilesProvider.notifier);
        expect(await notifier.add(name: '   ', avatarId: 'witch'), isNull);
        final p = await notifier.add(name: 'Sam', avatarId: 'dragon');
        expect(p!.avatarId, 'witch');
      },
    );

    test('saves players and loads them back, skipping bad records', () async {
      final store = MemoryProfileStore();
      await _container(store)
          .read(profilesProvider.notifier)
          .add(name: 'Ali', avatarId: 'vampire');
      await store.save([
        ...store.load().cast<Map<String, String>>(),
        {'id': '', 'name': 'broken', 'avatar': 'witch'},
      ]);

      final reloaded = _container(store).read(profilesProvider);
      expect(reloaded.map((p) => p.name), ['Ali']);
      expect(reloaded.last.avatarId, 'vampire');
    });

    test('stops at the maximum number of players', () async {
      final c = _container(MemoryProfileStore());
      final notifier = c.read(profilesProvider.notifier);
      for (var i = 0; i < ProfilesNotifier.maxProfiles + 2; i++) {
        await notifier.add(name: 'Kid $i', avatarId: 'pumpkin');
      }
      expect(c.read(profilesProvider).length, ProfilesNotifier.maxProfiles);
    });
  });

  group('Deleting profiles', () {
    test('max is 2 players', () {
      expect(ProfilesNotifier.maxProfiles, 2);
    });

    test('deleting a player keeps the other and saves it', () async {
      final store = MemoryProfileStore();
      final c = _container(store);
      final n = c.read(profilesProvider.notifier);
      final mia = await n.add(name: 'Mia', avatarId: 'witch');
      await n.add(name: 'Ali', avatarId: 'vampire');
      await n.remove(mia!.id);
      expect(c.read(profilesProvider).map((p) => p.name), ['Ali']);
      expect(_container(store).read(profilesProvider).map((p) => p.name), [
        'Ali',
      ]);
    });

    test('deleting the last player brings Boo back', () async {
      final c = _container(MemoryProfileStore());
      final n = c.read(profilesProvider.notifier);
      final mia = await n.add(name: 'Mia', avatarId: 'witch');
      await n.remove(mia!.id);
      expect(c.read(profilesProvider).single.id, Profile.booId);
    });

    test('Boo cannot be deleted', () async {
      final c = _container(MemoryProfileStore());
      await c.read(profilesProvider.notifier).remove(Profile.booId);
      expect(c.read(profilesProvider).single.id, Profile.booId);
    });

    test('a spot opens up again after deleting', () async {
      final c = _container(MemoryProfileStore());
      final n = c.read(profilesProvider.notifier);
      final mia = await n.add(name: 'Mia', avatarId: 'witch');
      await n.add(name: 'Ali', avatarId: 'vampire');
      expect(n.isFull, isTrue);
      expect(await n.add(name: 'Sam', avatarId: 'pumpkin'), isNull);
      await n.remove(mia!.id);
      expect(n.isFull, isFalse);
    });
  });

  group('ProfilePickerScreen', () {
    Future<ProviderContainer> pumpScreen(WidgetTester tester) async {
      final container = _container(MemoryProfileStore());
      final router = GoRouter(
        initialLocation: '/profiles',
        routes: [
          GoRoute(
            path: '/profiles',
            builder: (context, state) => const ProfilePickerScreen(),
          ),
          GoRoute(
            path: '/play',
            builder: (context, state) => const Text('games'),
          ),
          GoRoute(path: '/home', builder: (context, state) => const SizedBox()),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: HalloweenTheme.theme,
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();
      return container;
    }

    testWidgets('shows the sign, Boo, and Add Profile', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Who is playing today?'), findsOneWidget);
      expect(find.bySemanticsLabel('Play as Boo'), findsOneWidget);
      expect(find.text('Add Profile'), findsOneWidget);
    });

    testWidgets('adding a profile replaces the Boo card', (tester) async {
      await pumpScreen(tester);
      await tester.tap(find.text('Add Profile'));
      await tester.pump();
      // Let the bottom sheet finish sliding up.
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.enterText(find.byType(TextField), 'Mia');
      await tester.pump();
      await tester.ensureVisible(find.text('Save'));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.bySemanticsLabel('Play as Mia'), findsOneWidget);
      expect(find.bySemanticsLabel('Play as Boo'), findsNothing);
    });

    testWidgets('tapping a profile selects it and opens the games', (
      tester,
    ) async {
      final container = await pumpScreen(tester);
      await tester.tap(find.bySemanticsLabel('Play as Boo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(container.read(currentProfileIdProvider), Profile.booId);
      expect(find.text('games'), findsOneWidget);
    });
    testWidgets('Boo has no delete button', (tester) async {
      await pumpScreen(tester);
      expect(find.bySemanticsLabel('Delete Boo'), findsNothing);
    });

    testWidgets('Add Profile is disabled at 2 players', (tester) async {
      final container = await pumpScreen(tester);
      final n = container.read(profilesProvider.notifier);
      await n.add(name: 'Mia', avatarId: 'witch');
      await n.add(name: 'Ali', avatarId: 'vampire');
      await tester.pump();

      await tester.tap(find.text('Add Profile'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('New player'), findsNothing);
    });

    testWidgets('trash badge deletes after confirming', (tester) async {
      final container = await pumpScreen(tester);
      await container
          .read(profilesProvider.notifier)
          .add(name: 'Mia', avatarId: 'witch');
      await tester.pump();

      await tester.tap(find.bySemanticsLabel('Delete Mia'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Delete Mia?'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.bySemanticsLabel('Play as Mia'), findsNothing);
      expect(find.bySemanticsLabel('Play as Boo'), findsOneWidget);
    });

    testWidgets('Keep cancels the delete', (tester) async {
      final container = await pumpScreen(tester);
      await container
          .read(profilesProvider.notifier)
          .add(name: 'Mia', avatarId: 'witch');
      await tester.pump();

      await tester.tap(find.bySemanticsLabel('Delete Mia'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Keep'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.bySemanticsLabel('Play as Mia'), findsOneWidget);
    });
  });
}
