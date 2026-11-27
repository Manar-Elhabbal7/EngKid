import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:engkids/features/alphabet/models/alphabet.dart';
import 'package:engkids/features/forest/models/forest.dart';

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

  /// Says a Haunted Forest word from its recording (text-to-speech if the
  /// file is missing).
  Future<bool> sayWord(ForestWord word);

  Future<void> stop();
}

/// Plays the recorded letters (`assets/audio/letters/A.mp3` …) and forest
/// words (`assets/audio/words/owl.mp3` …). If a file is missing, the
/// phone's text-to-speech says it instead. The recordings were generated
/// with TTSMaker (see README credits).
class DeviceLetterVoice implements LetterVoice {
  final _player = AudioPlayer();
  final _tts = FlutterTts();
  Future<Set<String>>? _recorded;
  Future<void>? _ttsReady;
  var _generation = 0;
  Completer<void>? _cancel;

  @override
  Future<bool> say(AlphabetLetter letter) =>
      _play(asset: letter.audioAsset, spoken: letter.spoken);

  @override
  Future<bool> sayWord(ForestWord word) =>
      _play(asset: word.audioAsset, spoken: '${word.word}.');

  /// Plays [asset] if it's in the app, otherwise speaks [spoken].
  Future<bool> _play({String? asset, required String spoken}) async {
    await stop();
    final mine = ++_generation;
    final cancel = _cancel = Completer<void>();
    // Waits for the sound to end, or returns at once if stop() is called.
    Future<void> untilDone(Future<Object?> playing) =>
        Future.any([playing, cancel.future])
            .timeout(const Duration(seconds: 10));
    try {
      final file = asset;
      if (file != null &&
          (await (_recorded ??= _listRecorded())).contains(file)) {
        final done = _player.onPlayerComplete.first;
        await _player.play(AssetSource(file.substring('assets/'.length)));
        await untilDone(done);
      } else {
        await (_ttsReady ??= _setUpTts());
        await untilDone(_tts.speak(spoken));
      }
    } catch (e) {
      // No voice available on this device: don't block the child's
      // learning, the letter or word is still on screen.
      debugPrint('[LetterVoice] could not play "$spoken": $e');
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
      return manifest
          .listAssets()
          .where((a) => a.startsWith('assets/audio/'))
          .toSet();
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
