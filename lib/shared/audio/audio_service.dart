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
      if (_themeStarted) return;
      _themeStarted = true;
      await _music.play(AssetSource('audio/halloween_splash.mp3'));
    } catch (_) {
      _themeStarted = false;
    }
  }

  Future<void> toggleMute() async {
    muted = !muted;
    try {
      await _music.setVolume(muted ? 0 : _themeVolume);
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
