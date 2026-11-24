import 'package:flutter/material.dart';

/// A character a child can pick as their profile picture.
///
/// [asset] is used when set; otherwise [emoji] is drawn on the card colours.
/// If the [asset] file is missing, the emoji is shown instead, so the app
/// works before the character images are added.
class AvatarOption {
  const AvatarOption({
    required this.id,
    required this.label,
    required this.emoji,
    required this.top,
    required this.bottom,
    this.asset,
  });

  final String id;
  final String label;
  final String emoji;
  final Color top;
  final Color bottom;
  final String? asset;
}

abstract final class Avatars {
  static const boo = AvatarOption(
    id: 'boo',
    label: 'Boo',
    emoji: '👻',
    top: Color(0xFFB7BEF2),
    bottom: Color(0xFF5B5FB8),
    asset: 'assets/images/avatars/boo.png',
  );

  /// Characters a child can pick for a new profile (Boo is the placeholder).
  static const costumes = <AvatarOption>[
    AvatarOption(
      id: 'witch',
      label: 'Witch',
      emoji: '🧙',
      top: Color(0xFFC9A6F2),
      bottom: Color(0xFF6A3FB0),
      asset: 'assets/images/avatars/witch.png',
    ),
    AvatarOption(
      id: 'vampire',
      label: 'Vampire',
      emoji: '🧛',
      top: Color(0xFFD5C8F5),
      bottom: Color(0xFF7A5AB8),
      asset: 'assets/images/avatars/vampire.png',
    ),
    AvatarOption(
      id: 'pumpkin',
      label: 'Pumpkin',
      emoji: '🎃',
      top: Color(0xFFFFD2A0),
      bottom: Color(0xFFE8782A),
      asset: 'assets/images/avatars/pumpkin.png',
    ),
    AvatarOption(
      id: 'monster',
      label: 'Monster',
      emoji: '🧟',
      top: Color(0xFFC8E8B0),
      bottom: Color(0xFF5E9A4E),
      asset: 'assets/images/avatars/monster.png',
    ),
  ];

  static const all = <AvatarOption>[boo, ...costumes];

  /// Unknown ids (e.g. from an older save) fall back to Boo.
  static AvatarOption byId(String id) =>
      all.firstWhere((a) => a.id == id, orElse: () => boo);

  /// For new profiles: unknown ids fall back to the first costume.
  static AvatarOption costumeById(String id) =>
      costumes.firstWhere((a) => a.id == id, orElse: () => costumes.first);
}

/// One player on this device.
class Profile {
  const Profile({required this.id, required this.name, required this.avatarId});

  static const booId = 'boo';
  static const boo = Profile(id: booId, name: 'Boo', avatarId: 'boo');

  final String id;
  final String name;
  final String avatarId;

  AvatarOption get avatar => Avatars.byId(avatarId);

  Map<String, String> toMap() => {'id': id, 'name': name, 'avatar': avatarId};

  /// Returns null for malformed entries so one bad record can't crash loading.
  static Profile? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final name = raw['name'];
    final avatar = raw['avatar'];
    if (id is! String || name is! String || avatar is! String) return null;
    if (id.isEmpty || name.trim().isEmpty) return null;
    return Profile(id: id, name: name, avatarId: avatar);
  }
}
