import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Sound-effect IDs used across the app.
enum SfxType {
  /// Played on a correct answer / completed activity.
  chime,

  /// Played on a wrong answer — a soft ghost "wooo".
  woo,

  /// Played when navigating between rooms.
  creak,

  /// Played when a star is awarded.
  sparkle,
}

/// Thin wrapper around [AudioPlayer] for one-shot SFX playback.
///
/// Audio files are expected at:
///   assets/audio/chime.mp3
///   assets/audio/woo.mp3
///   assets/audio/creak.mp3
///   assets/audio/sparkle.mp3
///
/// Until real SFX files are added, [play] logs the event and no-ops silently.
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final _player = AudioPlayer();

  static const _files = {
    SfxType.chime: 'audio/chime.mp3',
    SfxType.woo: 'audio/woo.mp3',
    SfxType.creak: 'audio/creak.mp3',
    SfxType.sparkle: 'audio/sparkle.mp3',
  };

  Future<void> play(SfxType sfx) async {
    final path = _files[sfx]!;
    try {
      await _player.play(AssetSource(path));
    } catch (e) {
      // Audio file not yet present — log and continue gracefully.
      debugPrint('[AudioService] could not play $path: $e');
    }
  }
}
