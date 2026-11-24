import 'package:hive_flutter/hive_flutter.dart';

/// Where per-profile progress is kept, as `{profileId: progressMap}`.
abstract interface class ProgressStore {
  Map<String, Object?> load();
  Future<void> save(Map<String, Map<String, Object>> progress);
}

/// Used in tests and as a fallback when local storage can't be opened.
class MemoryProgressStore implements ProgressStore {
  MemoryProgressStore([Map<String, Map<String, Object>>? initial])
    : _data = {...?initial};

  Map<String, Map<String, Object>> _data;

  @override
  Map<String, Object?> load() => Map.of(_data);

  @override
  Future<void> save(Map<String, Map<String, Object>> progress) async {
    _data = Map.of(progress);
  }
}

/// Persists progress next to the profiles in the same Hive box.
class HiveProgressStore implements ProgressStore {
  HiveProgressStore(this._box);

  static const _key = 'progress';

  final Box<dynamic> _box;

  @override
  Map<String, Object?> load() {
    final raw = _box.get(_key);
    if (raw is! Map) return const {};
    return {
      for (final e in raw.entries)
        if (e.key is String) e.key as String: e.value,
    };
  }

  @override
  Future<void> save(Map<String, Map<String, Object>> progress) =>
      _box.put(_key, progress);
}
