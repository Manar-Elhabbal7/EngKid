import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engkids/features/profiles/data/profile_store.dart';
import 'package:engkids/features/profiles/models/profile.dart';

/// Overridden in `main.dart` with the Hive store. Defaults to memory so
/// widget tests work without device storage.
final profileStoreProvider = Provider<ProfileStore>((ref) {
  return MemoryProfileStore();
});

final profilesProvider = NotifierProvider<ProfilesNotifier, List<Profile>>(
  ProfilesNotifier.new,
);

/// The player picked on the "Who is playing today?" screen.
final currentProfileIdProvider = StateProvider<String>((ref) => Profile.booId);

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
    final clean = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.isEmpty || isFull) return null;
    final trimmed = clean.length > maxNameLength
        ? clean.substring(0, maxNameLength)
        : clean;
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
  }

  Future<void> _setPlayers(List<Profile> players) async {
    state = players.isEmpty ? const [Profile.boo] : players;
    await ref
        .read(profileStoreProvider)
        .save(players.map((p) => p.toMap()).toList());
  }
}
