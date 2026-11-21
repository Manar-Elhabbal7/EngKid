import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/screens/home_screen.dart';
import '../features/alphabet/screens/alphabet_screen.dart';
import '../features/vocabulary/screens/vocab_screen.dart';
import '../features/matching/screens/matching_screen.dart';
import '../features/quiz/screens/quiz_screen.dart';
import '../features/progress/screens/progress_screen.dart';

/// Named route paths used across the app.
abstract final class AppRoutes {
  static const home     = '/';
  static const alphabet = '/alphabet';
  static const vocab    = '/vocab';
  static const matching = '/matching';
  static const quiz     = '/quiz';
  static const progress = '/progress';
}

/// Spooky fade + slight scale transition used for every route.
///
/// Source: https://pub.dev/documentation/go_router/latest/go_router/CustomTransitionPage-class.html
CustomTransitionPage<T> _spookyPage<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeIn);
      final scale = Tween<double>(begin: 0.94, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOut),
      );
      return FadeTransition(
        opacity: fade,
        child: ScaleTransition(scale: scale, child: child),
      );
    },
  );
}

/// Top-level [GoRouter] instance.
///
/// Source: https://pub.dev/packages/go_router
final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      pageBuilder: (c, s) =>
          _spookyPage(context: c, state: s, child: const HomeScreen()),
    ),
    GoRoute(
      path: AppRoutes.alphabet,
      pageBuilder: (c, s) =>
          _spookyPage(context: c, state: s, child: const AlphabetScreen()),
    ),
    GoRoute(
      path: AppRoutes.vocab,
      pageBuilder: (c, s) =>
          _spookyPage(context: c, state: s, child: const VocabScreen()),
    ),
    GoRoute(
      path: AppRoutes.matching,
      pageBuilder: (c, s) =>
          _spookyPage(context: c, state: s, child: const MatchingScreen()),
    ),
    GoRoute(
      path: AppRoutes.quiz,
      pageBuilder: (c, s) =>
          _spookyPage(context: c, state: s, child: const QuizScreen()),
    ),
    GoRoute(
      path: AppRoutes.progress,
      pageBuilder: (c, s) =>
          _spookyPage(context: c, state: s, child: const ProgressScreen()),
    ),
  ],
);
