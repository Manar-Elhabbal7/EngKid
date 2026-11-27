import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:engkids/app/theme.dart';
import 'package:engkids/features/forest/models/forest.dart';
import 'package:engkids/features/lessons/lesson_session.dart';
import 'package:engkids/features/lessons/models/lesson.dart';
import 'package:engkids/features/progress/models/child_progress.dart';
import 'package:engkids/features/progress/providers/progress_provider.dart';
import 'package:engkids/features/spelling/models/spelling.dart';
import 'package:engkids/features/spelling/models/spelling_progress.dart';
import 'package:engkids/features/spelling/widgets/letter_slots.dart';
import 'package:engkids/features/spelling/widgets/letter_tile.dart';
import 'package:engkids/features/spelling/widgets/spell_picture.dart';
import 'package:engkids/shared/widgets/boo_speech.dart';
import 'package:engkids/shared/widgets/coin_burst.dart';
import 'package:engkids/shared/widgets/lesson_background.dart';
import 'package:engkids/shared/widgets/lesson_header.dart';
import 'package:engkids/shared/widgets/lesson_next_controls.dart';

/// Spell-It Quiz: look at the picture and tap the letter pumpkins in order
/// to spell its word. Each new word gives coins; after the last word the
/// lesson is finished, which opens Magic Cauldron.
class SpellingScreen extends ConsumerStatefulWidget {
  const SpellingScreen({super.key});

  @override
  ConsumerState<SpellingScreen> createState() => _SpellingScreenState();
}

class _SpellingScreenState extends ConsumerState<SpellingScreen>
    with WidgetsBindingObserver, LessonSession<SpellingScreen> {
  final _rng = math.Random();
  late int _index = myProgress.spellingResumeIndex;
  late List<String> _tiles = _shuffled();
  final _used = <int>{};
  final _shakes = <int, int>{};
  var _filled = 0;
  var _mistakes = 0;
  var _oops = false;

  ForestWord get _word => Spelling.words[_index];
  String get _letters => _word.word.toUpperCase();
  bool get _isLast => _index == Spelling.words.length - 1;
  bool get _done => _filled == _letters.length;

  /// The word's letters in a new order, never already spelled correctly.
  List<String> _shuffled() {
    final letters = _letters.split('');
    do {
      letters.shuffle(_rng);
    } while (letters.join() == _letters);
    return letters;
  }

  /// After a few wrong taps, the pumpkin with the needed letter glows.
  int? get _hintTile {
    if (_done || _mistakes < Spelling.hintAfterMistakes) return null;
    final needed = _letters[_filled];
    for (var i = 0; i < _tiles.length; i++) {
      if (!_used.contains(i) && _tiles[i] == needed) return i;
    }
    return null;
  }

  void _sayWord() {
    if (!audio.muted) voice.sayWord(_word);
  }

  Future<void> _tapTile(int i) async {
    if (_done || _used.contains(i)) return;
    if (_tiles[i] != _letters[_filled]) {
      HapticFeedback.heavyImpact();
      audio.playSfx('audio/woo.mp3');
      setState(() {
        _shakes[i] = (_shakes[i] ?? 0) + 1;
        _mistakes++;
        _oops = true;
      });
      return;
    }

    setState(() {
      _used.add(i);
      _filled++;
      _mistakes = 0;
      _oops = false;
    });
    if (!_done) {
      audio.playSfx('audio/sparkle.mp3');
      return;
    }

    final word = _word;
    audio.playSfx('audio/chime.mp3');
    _sayWord();
    // Coins only the first time this child spells the word.
    final earned = await earn((p) => p.withWordSpelled(word));
    if (earned > 0 && mounted) {
      setState(() {
        burstCoins = earned;
        burstId++;
      });
    }
  }

  void _prev() => stepBack(() {
    _index--;
    _tiles = _shuffled();
    _used.clear();
    _filled = 0;
    _mistakes = 0;
    _oops = false;
  });

  void _next() {
    if (!_isLast) {
      stepForward(() {
        _index++;
        _tiles = _shuffled();
        _used.clear();
        _filled = 0;
        _mistakes = 0;
        _oops = false;
      });
      return;
    }
    finishLesson(
      lesson: Lesson.quiz,
      message: 'You spelled all ${Spelling.words.length} words!',
      rule: (p) => p.withSpellingFinished(),
    );
  }

  String get _bubble {
    if (_done) {
      return _isLast ? 'You did it! Tap Finish!' : 'Great spelling! Tap Next!';
    }
    if (_hintTile != null) return 'Look for the glowing pumpkin!';
    if (_oops) return 'Oops! Try another letter!';
    if (_filled == 0) return 'Spell the word! Tap the letters.';
    return 'Keep going!';
  }

  /// Picture, slots and letter pumpkins, sized to fit [box].
  Widget _puzzle(BoxConstraints box) {
    final n = _letters.length;
    final picture = math.min(box.maxWidth * 0.5, box.maxHeight * 0.36);
    final slot = math.min(
      64.0,
      math.min((box.maxWidth - 24) / (n * 1.2), box.maxHeight * 0.13),
    );
    final tile = math.min(
      84.0,
      math.min((box.maxWidth - 12.0 * (n - 1)) / n, box.maxHeight * 0.2),
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            SpellPicture(
              word: _word,
              size: picture,
              glow: _done,
              onTap: _sayWord,
            ),
            if (burstId > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: CoinBurst(
                      key: ValueKey(burstId),
                      amount: burstCoins,
                    ),
                  ),
                ),
              ),
          ],
        ),
        LetterSlots(word: _letters, filled: _filled, size: slot),
        Wrap(
          spacing: 12,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < _tiles.length; i++)
              LetterTile(
                key: ValueKey('$_index-$i'),
                letter: _tiles[i],
                size: tile,
                used: _used.contains(i),
                hint: _hintTile == i,
                shakeToken: _shakes[i] ?? 0,
                onTap: () => _tapTile(i),
              ),
          ],
        ),
      ],
    );
  }

  Widget _controls() => LessonNextControls(
    isLast: _isLast,
    // Also open when this word was spelled before (e.g. after Prev).
    enabled: _done || myProgress.hasSpelled(_word),
    counter: '${_index + 1} / ${Spelling.words.length}',
    onNext: _next,
    onPrev: _index > 0 ? _prev : null,
  );

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(progressProvider)[profileId] ?? ChildProgress.empty;
    return Scaffold(
      backgroundColor: HalloweenColors.nightSky,
      body: LayoutBuilder(
        builder: (context, screen) {
          final wide = screen.maxWidth > screen.maxHeight;
          return Stack(
            fit: StackFit.expand,
            children: [
              LessonBackground(wide: wide),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Column(
                    children: [
                      LessonHeader(
                        title: Lesson.quiz.title,
                        coins: p.coins,
                        onBack: () => context.go('/play'),
                      ),
                      const SizedBox(height: 8),
                      Expanded(child: wide ? _wideLayout() : _tallLayout()),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Portrait: Boo and his bubble, the puzzle, then Next.
  Widget _tallLayout() => Column(
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const FloatingBoo(size: 96),
          const SizedBox(width: 4),
          Flexible(child: SpeechBubble(text: _bubble)),
        ],
      ),
      Expanded(child: LayoutBuilder(builder: (context, box) => _puzzle(box))),
      const SizedBox(height: 12),
      _controls(),
    ],
  );

  /// Landscape: Boo | puzzle | Next.
  Widget _wideLayout() => Row(
    children: [
      Expanded(
        flex: 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpeechBubble(text: _bubble),
            const FloatingBoo(size: 120),
          ],
        ),
      ),
      Expanded(
        flex: 5,
        child: LayoutBuilder(builder: (context, box) => _puzzle(box)),
      ),
      const SizedBox(width: 12),
      Expanded(flex: 3, child: Center(child: _controls())),
    ],
  );
}
