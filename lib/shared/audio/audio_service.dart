import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioServiceProvider = ChangeNotifierProvider<AudioService>((ref) {
  return AudioService();
});

/// Owns every sound in the app: the looping theme music and one-shot SFX.
///
/// Mute is enforced at the player level: whenever either player reports
/// that it started playing while [muted] is true, it is silenced again.
/// This covers playback that was already loading when mute was tapped
/// (e.g. the splash theme still fetching its asset).
class AudioService extends ChangeNotifier {
  AudioService({AudioPlayer? music, AudioPlayer? sfx})
    : _music = music ?? AudioPlayer(),
      _sfx = sfx ?? AudioPlayer() {
    _musicSub = _music.onPlayerStateChanged.listen((state) {
      if ((muted || _themePaused) && state == PlayerState.playing) {
        _silenceMusic();
      }
    }, onError: (Object _) {});
    _sfxSub = _sfx.onPlayerStateChanged.listen((state) {
      if (muted && state == PlayerState.playing) _silenceSfx();
    }, onError: (Object _) {});
  }

  final AudioPlayer _music;
  final AudioPlayer _sfx;
  late final StreamSubscription<PlayerState> _musicSub;
  late final StreamSubscription<PlayerState> _sfxSub;

  static const _themeAsset = 'audio/halloween_splash.mp3';
  static const _themeVolume = 0.82;
  static const _sfxVolume = 1.0;

  var muted = false;

  /// True once the theme source has been loaded into [_music].
  var _themeLoaded = false;

  /// In-flight theme start, shared so concurrent callers don't double-load.
  Future<void>? _themeLoading;

  /// True while a lesson needs quiet (e.g. hearing letters). The theme
  /// stays paused even if a screen asks for it, until [resumeTheme].
  var _themePaused = false;
  bool get themePaused => _themePaused;

  /// Pauses the background music so the child can focus on a lesson.
  /// Sound effects and lesson audio still play.
  Future<void> pauseTheme() async {
    _themePaused = true;
    await _silenceMusic();
  }

  /// Brings the background music back after [pauseTheme], unless muted.
  Future<void> resumeTheme() async {
    _themePaused = false;
    if (!muted) await playTheme();
  }

  Future<void> playTheme() {
    if (_themeLoaded) {
      return muted || _themePaused ? _silenceMusic() : _resumeMusic();
    }
    return _themeLoading ??= _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.setVolume(muted ? 0 : _themeVolume);
      await _music.setSource(AssetSource(_themeAsset));
      _themeLoaded = true;
      // Re-check after loading: mute may have been tapped meanwhile.
      if (!muted && !_themePaused) await _resumeMusic();
    } catch (_) {
      _themeLoaded = false;
    } finally {
      _themeLoading = null;
    }
  }

  Future<void> toggleMute() async {
    muted = !muted;
    notifyListeners();
    try {
      if (muted) {
        await Future.wait([_silenceMusic(), _silenceSfx()]);
      } else {
        await _sfx.setVolume(_sfxVolume);
        await playTheme();
      }
    } catch (_) {}
  }

  Future<void> playSfx(String asset) async {
    if (muted) return;
    try {
      await _sfx.setVolume(_sfxVolume);
      await _sfx.play(AssetSource(asset));
      // Mute may have been tapped while the asset was loading.
      if (muted) await _silenceSfx();
    } catch (_) {}
  }

  Future<void> _resumeMusic() async {
    try {
      await _music.setVolume(_themeVolume);
      await _music.resume();
      if (muted || _themePaused) await _silenceMusic();
    } catch (_) {}
  }

  Future<void> _silenceMusic() async {
    try {
      await _music.setVolume(0);
      await _music.pause();
    } catch (_) {}
  }

  Future<void> _silenceSfx() async {
    try {
      await _sfx.setVolume(0);
      await _sfx.stop();
    } catch (_) {}
  }

  @override
  void dispose() {
    _musicSub.cancel();
    _sfxSub.cancel();
    _music.dispose();
    _sfx.dispose();
    super.dispose();
  }
}
