import 'dart:async';

import 'package:engkids/features/alphabet/models/alphabet.dart';
import 'package:engkids/shared/audio/letter_voice.dart';

/// A voice the test finishes by hand, like a letter that takes time to say.
class FakeVoice implements LetterVoice {
  Completer<bool>? _playing;
  final said = <String>[];

  @override
  Future<bool> say(AlphabetLetter letter) {
    said.add(letter.letter);
    return (_playing = Completer<bool>()).future;
  }

  @override
  Future<bool> sayWord(String word) {
    said.add(word);
    return (_playing = Completer<bool>()).future;
  }

  void finish() => _playing?.complete(true);

  @override
  Future<void> stop() async {
    final p = _playing;
    if (p != null && !p.isCompleted) p.complete(false);
  }
}
