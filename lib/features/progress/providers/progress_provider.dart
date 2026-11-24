import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engkids/features/progress/data/progress_store.dart';
import 'package:engkids/features/progress/models/child_progress.dart';

/// Overridden in `main.dart` with the Hive store.
final progressStoreProvider = Provider<ProgressStore>((ref) {
  return MemoryProgressStore();
});

/// Progress for every profile, keyed by profile id.
final progressProvider =
    NotifierProvider<ProgressNotifier, Map<String, ChildProgress>>(
      ProgressNotifier.new,
    );

class ProgressNotifier extends Notifier<Map<String, ChildProgress>> {
  @override
  Map<String, ChildProgress> build() {
    return {
      for (final e in ref.read(progressStoreProvider).load().entries)
        e.key: ChildProgress.fromMap(e.value),
    };
  }

  ChildProgress of(String profileId) => state[profileId] ?? ChildProgress.empty;

  /// For the games: change one child's progress and save it.
  Future<void> update(
    String profileId,
    ChildProgress Function(ChildProgress current) change,
  ) => _save({...state, profileId: change(of(profileId))});

  /// Called when a profile is deleted so its progress doesn't linger.
  Future<void> forget(String profileId) async {
    if (!state.containsKey(profileId)) return;
    await _save({...state}..remove(profileId));
  }

  Future<void> _save(Map<String, ChildProgress> next) async {
    state = next;
    await ref.read(progressStoreProvider).save({
      for (final e in next.entries) e.key: e.value.toMap(),
    });
  }
}
