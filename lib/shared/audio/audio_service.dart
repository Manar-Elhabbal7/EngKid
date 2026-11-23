import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioServiceProvider = ChangeNotifierProvider<AudioService>((ref) {
  return AudioService();
});

class AudioService extends ChangeNotifier {
  AudioService({AudioPlayer? music, AudioPlayer? sfx})
    : _music = music ?? AudioPlayer(),
      _sfx = sfx ?? AudioPlayer();

  final AudioPlayer _music;
  final AudioPlayer _sfx;

  static const _themeVolume = 0.82;

  var muted = false;
  var _themeStarted = false;

  Future<void> playTheme() async {
    try {
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.setVolume(muted ? 0 : _themeVolume);
      if (_themeStarted) {
        if (muted) {
          await _music.pause();
        }
        return;
      }
      _themeStarted = true;
      if (muted) {
        await _music.setSource(AssetSource('audio/halloween_splash.mp3'));
      } else {
        await _music.play(AssetSource('audio/halloween_splash.mp3'));
      }
    } catch (_) {
      _themeStarted = false;
    }
  }

  Future<void> toggleMute() async {
    muted = !muted;
    try {
      if (muted) {
        await _music.setVolume(0);
        await _music.pause();
        await _sfx.stop();
      } else {
        await _music.setVolume(_themeVolume);
        if (_themeStarted) {
          await _music.resume();
        } else {
          await playTheme();
        }
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> playSfx(String asset) async {
    if (muted) return;
    try {
      await _sfx.play(AssetSource(asset));
    } catch (_) {}
  }

  @override
  void dispose() {
    _music.dispose();
    _sfx.dispose();
    super.dispose();
  }
}
