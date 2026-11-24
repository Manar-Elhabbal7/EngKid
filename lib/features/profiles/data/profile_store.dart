import 'package:hive_flutter/hive_flutter.dart';

/// Where the profile list is kept. Raw maps so the store stays dumb;
/// parsing and validation live in `Profile.fromMap`.
abstract interface class ProfileStore {
  List<Object?> load();
  Future<void> save(List<Map<String, String>> profiles);

  /// The player last chosen on "Who is playing today?", if any.
  String? loadCurrentId();
  Future<void> saveCurrentId(String id);
}

/// Used in tests and as a fallback when local storage can't be opened.
class MemoryProfileStore implements ProfileStore {
  MemoryProfileStore([List<Map<String, String>>? initial])
    : _data = [...?initial];

  List<Map<String, String>> _data;
  String? _currentId;

  @override
  List<Object?> load() => List.of(_data);

  @override
  Future<void> save(List<Map<String, String>> profiles) async {
    _data = List.of(profiles);
  }

  @override
  String? loadCurrentId() => _currentId;

  @override
  Future<void> saveCurrentId(String id) async => _currentId = id;
}

/// Persists profiles on the device so they survive app restarts.
class HiveProfileStore implements ProfileStore {
  HiveProfileStore(this._box);

  static const boxName = 'engkids';
  static const _key = 'profiles';
  static const _currentKey = 'current_profile';

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

  @override
  String? loadCurrentId() {
    final raw = _box.get(_currentKey);
    return raw is String ? raw : null;
  }

  @override
  Future<void> saveCurrentId(String id) => _box.put(_currentKey, id);
}
