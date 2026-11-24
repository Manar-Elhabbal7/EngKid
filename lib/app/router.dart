import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:engkids/features/alphabet/screens/alphabet_screen.dart';
import 'package:engkids/features/forest/screens/forest_screen.dart';
import 'package:engkids/features/matching/screens/matching_screen.dart';
import 'package:engkids/features/spelling/screens/spelling_screen.dart';
import 'package:engkids/features/home/screens/home_screen.dart';
import 'package:engkids/features/home/screens/parents_screen.dart';
import 'package:engkids/features/home/screens/play_picker_screen.dart';
import 'package:engkids/features/profiles/screens/profile_picker_screen.dart';
import 'package:engkids/features/splash/screens/splash_screen.dart';

bool splashCompleted = false;

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

GoRouter createAppRouter({
  String initialLocation = '/',
  bool skipSplash = false,
}) {
  if (skipSplash) {
    splashCompleted = true;
  }

  return GoRouter(
    initialLocation: initialLocation,
    redirect: (context, state) {
      // Always show the splash screen first on app launch or hot restart
      if (!splashCompleted && state.matchedLocation != '/') {
        return '/';
      }
      return null;
    },
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
        path: '/profiles',
        name: 'profiles',
        pageBuilder: (context, state) =>
            _fadePage(key: state.pageKey, child: const ProfilePickerScreen()),
      ),
      GoRoute(
        path: '/play',
        name: 'play',
        pageBuilder: (context, state) =>
            _fadePage(key: state.pageKey, child: const PlayPickerScreen()),
      ),
      GoRoute(
        path: '/play/alphabet',
        name: 'alphabet',
        pageBuilder: (context, state) =>
            _fadePage(key: state.pageKey, child: const AlphabetScreen()),
      ),
      GoRoute(
        path: '/play/forest',
        name: 'forest',
        pageBuilder: (context, state) =>
            _fadePage(key: state.pageKey, child: const ForestScreen()),
      ),
      GoRoute(
        path: '/play/matching',
        name: 'matching',
        pageBuilder: (context, state) =>
            _fadePage(key: state.pageKey, child: const MatchingScreen()),
      ),
      GoRoute(
        path: '/play/quiz',
        name: 'quiz',
        pageBuilder: (context, state) =>
            _fadePage(key: state.pageKey, child: const SpellingScreen()),
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
