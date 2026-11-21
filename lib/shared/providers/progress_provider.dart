import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Hive box name for all progress data.
const _kBoxName = 'engkids_progress';

/// Keys inside the Hive box.
abstract final class ProgressKeys {
  static const visitedLetters = 'visited_letters';
  static const learnedWords   = 'learned_words';
  static const totalStars     = 'total_stars';
}

// ─────────────────────────────────────────────────────────────────────────────
// Raw Hive box — opened once in main.dart before runApp.
// ─────────────────────────────────────────────────────────────────────────────

/// Opens (or returns) the progress Hive box.
Future<Box> openProgressBox() => Hive.openBox(_kBoxName);

// ─────────────────────────────────────────────────────────────────────────────
// Riverpod providers
// ─────────────────────────────────────────────────────────────────────────────

/// Set of letter strings the child has visited, e.g. {'A', 'B', 'C'}.
final visitedLettersProvider =
    StateNotifierProvider<_SetNotifier, Set<String>>((ref) {
  final box = Hive.box(_kBoxName);
  final stored = (box.get(ProgressKeys.visitedLetters) as List?)
          ?.cast<String>()
          .toSet() ??
      {};
  return _SetNotifier(box, ProgressKeys.visitedLetters, stored);
});

/// Set of word strings the child has learned.
final learnedWordsProvider =
    StateNotifierProvider<_SetNotifier, Set<String>>((ref) {
  final box = Hive.box(_kBoxName);
  final stored = (box.get(ProgressKeys.learnedWords) as List?)
          ?.cast<String>()
          .toSet() ??
      {};
  return _SetNotifier(box, ProgressKeys.learnedWords, stored);
});

/// Total stars earned across all activities.
final totalStarsProvider =
    StateNotifierProvider<_IntNotifier, int>((ref) {
  final box = Hive.box(_kBoxName);
  return _IntNotifier(box, ProgressKeys.totalStars,
      box.get(ProgressKeys.totalStars, defaultValue: 0) as int);
});

// ─────────────────────────────────────────────────────────────────────────────
// Generic notifiers
// ─────────────────────────────────────────────────────────────────────────────

class _SetNotifier extends StateNotifier<Set<String>> {
  _SetNotifier(this._box, this._key, super.initial);

  final Box _box;
  final String _key;

  void add(String value) {
    if (state.contains(value)) return;
    state = {...state, value};
    _box.put(_key, state.toList());
  }

  bool contains(String value) => state.contains(value);
}

class _IntNotifier extends StateNotifier<int> {
  _IntNotifier(this._box, this._key, super.initial);

  final Box _box;
  final String _key;

  void increment([int by = 1]) {
    state = state + by;
    _box.put(_key, state);
  }
}
