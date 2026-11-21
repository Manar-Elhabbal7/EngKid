import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Wraps [FlutterTts] with child-friendly defaults.
///
/// Language : en-US
/// Pitch    : 1.1  (slightly higher = friendlier)
/// Rate     : 0.45 (slower → easier for young learners)
///
/// Source: https://pub.dev/packages/flutter_tts
class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    await _tts.setLanguage('en-US');
    await _tts.setPitch(1.1);
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    // Ensure completion callbacks fire before we mark ready
    await _tts.awaitSpeakCompletion(true);
    _ready = true;
    debugPrint('[TtsService] initialised');
  }

  /// Speaks [text] aloud. Stops any current speech first.
  Future<void> speak(String text) async {
    if (!_ready) await init();
    await _tts.stop();
    await _tts.speak(text);
  }

  /// Speaks a single letter with extra-clear pronunciation.
  /// e.g. "A" → says "A is for Apple"
  Future<void> speakLetter(String letter, String exampleWord) async {
    await speak('$letter is for $exampleWord');
  }

  Future<void> stop() async => _tts.stop();
}
