import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:engkids/features/alphabet/models/alphabet.dart';
import 'package:engkids/features/forest/models/forest.dart';

/// Catches misnamed recordings (e.g. `pumbkin.mp3`), which would silently
/// fall back to text-to-speech in the app.
void main() {
  test('every letter has its recording', () {
    final missing = Alphabet.letters
        .map((l) => l.audioAsset)
        .where((path) => !File(path).existsSync())
        .toList();
    expect(missing, isEmpty);
  });

  test('every Haunted Forest word has its recording', () {
    final missing = Forest.words
        .map((w) => w.audioAsset)
        .where((path) => !File(path).existsSync())
        .toList();
    expect(missing, isEmpty);
  });
}
