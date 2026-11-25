import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:engkids/app/theme.dart';
import 'package:engkids/features/home/screens/home_screen.dart';
import 'package:engkids/features/home/screens/parents_screen.dart';
import 'package:engkids/features/home/screens/play_picker_screen.dart';
import 'package:engkids/features/profiles/screens/profile_picker_screen.dart';
import 'package:engkids/features/splash/screens/splash_screen.dart';

Widget _app(GoRouter router) {
  return ProviderScope(
    child: MaterialApp.router(
      theme: HalloweenTheme.theme,
      routerConfig: router,
    ),
  );
}

void main() {
  testWidgets('splash screen shows Halloween loading copy', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const SplashScreen(holdFor: Duration(days: 1)),
        ),
        GoRoute(path: '/home', builder: (context, state) => const SizedBox()),
      ],
    );

    await tester.pumpWidget(_app(router));
    await tester.pump();

    expect(find.text('Boo is waking up...'), findsOneWidget);
    expect(
      find.bySemanticsLabel('EngKids haunted mansion with Boo the ghost'),
      findsOneWidget,
    );
  });

  testWidgets('home shows play, parents, mute; play opens profiles', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/profiles',
          builder: (context, state) => const ProfilePickerScreen(),
        ),
        GoRoute(
          path: '/play',
          builder: (context, state) => const PlayPickerScreen(),
        ),
        GoRoute(
          path: '/parents',
          builder: (context, state) => const ParentsScreen(),
        ),
      ],
    );

    await tester.pumpWidget(_app(router));
    await tester.pump();

    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Parents'), findsOneWidget);
    expect(find.byTooltip('Mute music'), findsOneWidget);

    await tester.tap(find.text('Play'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Who is playing today?'), findsOneWidget);
  });

  testWidgets('home shows the whole welcome scene on a wide web window', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      ],
    );
    await tester.pumpWidget(_app(router));
    await tester.pump();
    expect(tester.takeException(), isNull);
    final scene = tester.widget<Image>(
      find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.semanticLabel == 'Boo the ghost waving in a Halloween forest',
      ),
    );
    expect(scene.fit, BoxFit.contain, reason: 'whole scene, not zoomed in');
    expect(find.text('Play'), findsOneWidget);
  });
}
