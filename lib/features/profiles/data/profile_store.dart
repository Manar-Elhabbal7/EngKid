import 'package:hive_flutter/hive_flutter.dart';

/// Where the profile list is kept. Raw maps so the store stays dumb;
/// parsing and validation live in `Profile.fromMap`.
abstract interface class ProfileStore {
  List<Object?> load();
  Future<void> save(List<Map<String, String>> profiles);
}

/// Used in tests and as a fallback when local storage can't be opened.
class MemoryProfileStore implements ProfileStore {
  MemoryProfileStore([List<Map<String, String>>? initial])
    : _data = [...?initial];

  List<Map<String, String>> _data;

  @override
  List<Object?> load() => List.of(_data);

  @override
  Future<void> save(List<Map<String, String>> profiles) async {
    _data = List.of(profiles);
  }
}

/// Persists profiles on the device so they survive app restarts.
class HiveProfileStore implements ProfileStore {
  HiveProfileStore(this._box);

  static const boxName = 'engkids';
  static const _key = 'profiles';

  final Box<dynamic> _box;

  /// Opens the app's single Hive box (profiles and progress live in it).
  static Future<Box<dynamic>> openBox() async {
    await Hive.initFlutter();
    return Hive.openBox<dynamic>(boxName);
  }

  @override
  List<Object?> load() {
    final raw = _box.get(_key);
    return raw is List ? List<Object?>.of(raw) : const [];
  }

  @override
  Future<void> save(List<Map<String, String>> profiles) =>
      _box.put(_key, profiles);
}
