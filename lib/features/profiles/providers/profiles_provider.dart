import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engkids/features/profiles/data/profile_store.dart';
import 'package:engkids/features/profiles/models/profile.dart';
import 'package:engkids/features/progress/providers/progress_provider.dart';

/// Overridden in `main.dart` with the Hive store. Defaults to memory so
/// widget tests work without device storage.
final profileStoreProvider = Provider<ProfileStore>((ref) {
  return MemoryProfileStore();
});

final profilesProvider = NotifierProvider<ProfilesNotifier, List<Profile>>(
  ProfilesNotifier.new,
);

/// Id of the player picked on "Who is playing today?". Saved on the device,
/// so it survives restarts. Null until someone is picked.
final currentProfileIdProvider =
    NotifierProvider<CurrentProfileIdNotifier, String?>(
      CurrentProfileIdNotifier.new,
    );

/// The chosen player. If nobody was picked, or the picked player was
/// deleted, it's the first saved player, and Boo only when there are none.
final currentProfileProvider = Provider<Profile>((ref) {
  final id = ref.watch(currentProfileIdProvider);
  final profiles = ref.watch(profilesProvider);
  return profiles.firstWhere((p) => p.id == id, orElse: () => profiles.first);
});

class CurrentProfileIdNotifier extends Notifier<String?> {
  @override
  String? build() => ref.read(profileStoreProvider).loadCurrentId();

  Future<void> select(String id) async {
    state = id;
    await ref.read(profileStoreProvider).saveCurrentId(id);
  }
}

class ProfilesNotifier extends Notifier<List<Profile>> {
  static const maxProfiles = 2;
  static const maxNameLength = 12;

  @override
  List<Profile> build() {
    final saved = _saved(ref.read(profileStoreProvider).load());
    // Boo is a placeholder shown only until the first real player is added.
    return saved.isEmpty ? const [Profile.boo] : saved;
  }

  static List<Profile> _saved(List<Object?> raw) => raw
      .map(Profile.fromMap)
      .whereType<Profile>()
      .where((p) => p.id != Profile.booId)
      .toList();

  /// Players the child created (never includes the Boo placeholder).
  List<Profile> get _players =>
      state.where((p) => p.id != Profile.booId).toList();

  bool get isFull => _players.length >= maxProfiles;

  /// Adds a player. Returns the new profile, or null if the name is blank
  /// or the list is already full.
  Future<Profile?> add({required String name, required String avatarId}) async {
    final trimmed = cleanName(name);
    if (trimmed == null || isFull) return null;
    final profile = Profile(
      id: 'p${DateTime.now().microsecondsSinceEpoch}',
      name: trimmed,
      avatarId: Avatars.costumeById(avatarId).id,
    );
    // The first real player takes Boo's place.
    await _setPlayers([..._players, profile]);
    return profile;
  }

  /// Deletes a player. Boo comes back when the last player is removed.
  /// Boo himself can't be deleted.
  Future<void> remove(String id) async {
    if (id == Profile.booId) return;
    await _setPlayers(_players.where((p) => p.id != id).toList());
    await ref.read(progressProvider.notifier).forget(id);
  }

  /// Changes a player's name. Returns false for a blank name or for Boo.
  Future<bool> rename(String id, String name) async {
    final trimmed = cleanName(name);
    if (trimmed == null || id == Profile.booId) return false;
    if (!_players.any((p) => p.id == id)) return false;
    await _setPlayers([
      for (final p in _players)
        p.id == id ? Profile(id: p.id, name: trimmed, avatarId: p.avatarId) : p,
    ]);
    return true;
  }

  /// Collapses spaces and caps the length; null when nothing is left.
  static String? cleanName(String name) {
    final clean = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.isEmpty) return null;
    return clean.length > maxNameLength
        ? clean.substring(0, maxNameLength)
        : clean;
  }

  Future<void> _setPlayers(List<Profile> players) async {
    state = players.isEmpty ? const [Profile.boo] : players;
    await ref
        .read(profileStoreProvider)
        .save(players.map((p) => p.toMap()).toList());
  }
}
