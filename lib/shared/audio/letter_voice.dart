import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:engkids/features/alphabet/models/alphabet.dart';

/// Overridden with a fake in tests.
final letterVoiceProvider = Provider<LetterVoice>((ref) {
  final voice = DeviceLetterVoice();
  ref.onDispose(voice.dispose);
  return voice;
});

abstract interface class LetterVoice {
  /// Says [letter] and completes when it has finished playing.
  /// Returns false if it was stopped before the end.
  Future<bool> say(AlphabetLetter letter);

  Future<void> stop();
}

/// Plays the recorded `assets/audio/letters/A.mp3` … `Z.mp3`.
/// If a file is missing, the phone's text-to-speech says "A. A is for Apple."
class DeviceLetterVoice implements LetterVoice {
  static const _folder = 'assets/audio/letters/';

  final _player = AudioPlayer();
  final _tts = FlutterTts();
  Future<Set<String>>? _recorded;
  Future<void>? _ttsReady;
  var _generation = 0;
  Completer<void>? _cancel;

  @override
  Future<bool> say(AlphabetLetter letter) async {
    await stop();
    final mine = ++_generation;
    final cancel = _cancel = Completer<void>();
    // Waits for the sound to end, or returns at once if stop() is called.
    Future<void> untilDone(Future<Object?> playing) =>
        Future.any([playing, cancel.future])
            .timeout(const Duration(seconds: 10));
    try {
      final file = letter.audioAsset;
      if ((await (_recorded ??= _listRecorded())).contains(file)) {
        final done = _player.onPlayerComplete.first;
        await _player.play(AssetSource(file.substring('assets/'.length)));
        await untilDone(done);
      } else {
        await (_ttsReady ??= _setUpTts());
        await untilDone(_tts.speak(letter.spoken));
      }
    } catch (e) {
      // No voice available on this device: don't block the child's
      // learning, the letter is still on screen.
      debugPrint('[LetterVoice] could not play ${letter.letter}: $e');
    }
    return mine == _generation;
  }

  @override
  Future<void> stop() async {
    _generation++;
    final cancel = _cancel;
    if (cancel != null && !cancel.isCompleted) cancel.complete();
    try {
      await _player.stop();
      await _tts.stop();
    } catch (_) {}
  }

  Future<Set<String>> _listRecorded() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      return manifest.listAssets().where((a) => a.startsWith(_folder)).toSet();
    } catch (_) {
      return const {};
    }
  }

  /// Child-friendly settings from the project steering doc.
  Future<void> _setUpTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setPitch(1.1);
    await _tts.setSpeechRate(0.5);
    await _tts.awaitSpeakCompletion(true);
  }

  void dispose() {
    _player.dispose();
    _tts.stop();
  }
}
