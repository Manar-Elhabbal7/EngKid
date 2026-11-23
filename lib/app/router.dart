import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:engkids/features/home/screens/home_screen.dart';
import 'package:engkids/features/home/screens/parents_screen.dart';
import 'package:engkids/features/home/screens/play_picker_screen.dart';
import 'package:engkids/features/splash/screens/splash_screen.dart';

CustomTransitionPage<void> _fadePage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondary, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

GoRouter createAppRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        pageBuilder: (context, state) =>
            _fadePage(key: state.pageKey, child: const SplashScreen()),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        pageBuilder: (context, state) =>
            _fadePage(key: state.pageKey, child: const HomeScreen()),
      ),
      GoRoute(
        path: '/play',
        name: 'play',
        pageBuilder: (context, state) =>
            _fadePage(key: state.pageKey, child: const PlayPickerScreen()),
      ),
      GoRoute(
        path: '/parents',
        name: 'parents',
        pageBuilder: (context, state) =>
            _fadePage(key: state.pageKey, child: const ParentsScreen()),
      ),
    ],
  );
}
