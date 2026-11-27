import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:engkids/app/theme.dart';
import 'package:engkids/features/forest/models/forest.dart';
import 'package:engkids/features/lessons/lesson_session.dart';
import 'package:engkids/features/lessons/models/lesson.dart';
import 'package:engkids/features/matching/models/matching.dart';
import 'package:engkids/features/matching/models/matching_progress.dart';
import 'package:engkids/features/matching/widgets/match_board.dart';
import 'package:engkids/features/progress/models/child_progress.dart';
import 'package:engkids/features/progress/providers/progress_provider.dart';
import 'package:engkids/shared/widgets/boo_speech.dart';
import 'package:engkids/shared/widgets/coin_burst.dart';
import 'package:engkids/shared/widgets/lesson_background.dart';
import 'package:engkids/shared/widgets/lesson_header.dart';
import 'package:engkids/shared/widgets/lesson_next_controls.dart';

/// Word Matching: join each Haunted Forest picture to its word, four at a
/// time. Each new pair gives coins; after the last round the lesson is
/// finished, which opens Spell-It Quiz.
class MatchingScreen extends ConsumerStatefulWidget {
  const MatchingScreen({super.key});

  @override
  ConsumerState<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends ConsumerState<MatchingScreen>
    with WidgetsBindingObserver, LessonSession<MatchingScreen> {
  final _rng = math.Random();
  late int _round = myProgress.matchingResumeRound;
  late List<ForestWord> _words = _shuffled();
  final _matched = <String>{};
  final _shakes = <String, int>{};
  String? _pickedPicture;
  String? _pickedWord;
  var _oops = false;

  List<ForestWord> get _pictures => Matching.rounds[_round];
  bool get _isLast => _round == Matching.rounds.length - 1;
  bool get _roundDone => _matched.length == _pictures.length;

  /// The words in a new order, never straight across from their pictures.
  List<ForestWord> _shuffled() {
    final words = List.of(_pictures);
    do {
      words.shuffle(_rng);
    } while (_listEquals(words, _pictures));
    return words;
  }

  static bool _listEquals(List<ForestWord> a, List<ForestWord> b) =>
      List.generate(a.length, (i) => a[i] == b[i]).every((same) => same);

  void _tapPicture(ForestWord w) {
    if (_matched.contains(w.key)) return;
    audio.playSfx('audio/sparkle.mp3');
    setState(() {
      _oops = false;
      _pickedPicture = _pickedPicture == w.key ? null : w.key;
    });
    _tryMatch();
  }

  void _tapWord(ForestWord w) {
    // Hearing the word helps children who can't read yet.
    if (!audio.muted) voice.sayWord(w);
    if (_matched.contains(w.key)) return;
    setState(() {
      _oops = false;
      _pickedWord = _pickedWord == w.key ? null : w.key;
    });
    _tryMatch();
  }

  Future<void> _tryMatch() async {
    final picture = _pickedPicture;
    final word = _pickedWord;
    if (picture == null || word == null) return;

    if (picture != word) {
      HapticFeedback.heavyImpact();
      audio.playSfx('audio/woo.mp3');
      setState(() {
        _shakes['p:$picture'] = (_shakes['p:$picture'] ?? 0) + 1;
        _shakes['w:$word'] = (_shakes['w:$word'] ?? 0) + 1;
        _pickedPicture = null;
        _pickedWord = null;
        _oops = true;
      });
      return;
    }

    final pair = _pictures.firstWhere((w) => w.key == picture);
    audio.playSfx('audio/chime.mp3');
    setState(() {
      _matched.add(pair.key);
      _pickedPicture = null;
      _pickedWord = null;
    });
    // Coins only the first time this child matches the pair.
    final earned = await earn((p) => p.withPairMatched(pair));
    if (earned > 0 && mounted) {
      setState(() {
        burstCoins = earned;
        burstId++;
      });
    }
  }

  void _prev() => stepBack(() {
    _round--;
    _words = _shuffled();
    _matched.clear();
    _pickedPicture = null;
    _pickedWord = null;
    _oops = false;
  });

  void _next() {
    if (!_isLast) {
      stepForward(() {
        _round++;
        _words = _shuffled();
        _matched.clear();
        _pickedPicture = null;
        _pickedWord = null;
        _oops = false;
      });
      return;
    }
    finishLesson(
      lesson: Lesson.matching,
      message: 'You matched all ${Forest.words.length} words!',
      rule: (p) => p.withMatchingFinished(),
    );
  }

  String get _bubble {
    if (_oops) return 'Oops! Try again!';
    if (_roundDone) {
      return _isLast ? 'You did it! Tap Finish!' : 'Great job! Tap Next!';
    }
    if (_pickedPicture != null) return 'Now tap its word!';
    if (_pickedWord != null) return 'Now tap its picture!';
    return 'Match each picture to its word!';
  }

  Widget _board() => Stack(
    clipBehavior: Clip.none,
    children: [
      MatchBoard(
        pictures: _pictures,
        words: _words,
        matched: _matched,
        selectedPicture: _pickedPicture,
        selectedWord: _pickedWord,
        shakes: _shakes,
        onPictureTap: _tapPicture,
        onWordTap: _tapWord,
      ),
      if (burstId > 0)
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: CoinBurst(key: ValueKey(burstId), amount: burstCoins),
            ),
          ),
        ),
    ],
  );

  Widget _controls() => LessonNextControls(
    isLast: _isLast,
    // Also open when this round was finished before (e.g. after Prev).
    enabled: _roundDone || myProgress.roundDone(_round),
    counter: 'Round ${_round + 1} / ${Matching.rounds.length}',
    onNext: _next,
    onPrev: _round > 0 ? _prev : null,
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
                        title: Lesson.matching.title,
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

  /// Portrait: Boo and his bubble on top, the board, then Next.
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
      const SizedBox(height: 10),
      Expanded(child: _board()),
      const SizedBox(height: 12),
      _controls(),
    ],
  );

  /// Landscape: Boo | board | Next.
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
      Expanded(flex: 6, child: _board()),
      const SizedBox(width: 12),
      Expanded(flex: 3, child: Center(child: _controls())),
    ],
  );
}
