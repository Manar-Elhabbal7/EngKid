import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:engkids/app/theme.dart';
import 'package:engkids/features/cauldron/models/cauldron.dart';
import 'package:engkids/features/cauldron/models/cauldron_progress.dart';
import 'package:engkids/features/cauldron/widgets/ingredient_orb.dart';
import 'package:engkids/features/cauldron/widgets/magic_cauldron.dart';
import 'package:engkids/features/forest/models/forest.dart';
import 'package:engkids/features/lessons/lesson_session.dart';
import 'package:engkids/features/lessons/models/lesson.dart';
import 'package:engkids/features/progress/models/child_progress.dart';
import 'package:engkids/features/progress/providers/progress_provider.dart';
import 'package:engkids/shared/widgets/boo_speech.dart';
import 'package:engkids/shared/widgets/coin_burst.dart';
import 'package:engkids/shared/widgets/lesson_background.dart';
import 'package:engkids/shared/widgets/lesson_header.dart';
import 'package:engkids/shared/widgets/lesson_next_controls.dart';

/// Magic Cauldron, the last lesson: Boo says an ingredient, the child finds
/// it among three floating bubbles and drops it in the pot.
class CauldronScreen extends ConsumerStatefulWidget {
  const CauldronScreen({super.key});

  @override
  ConsumerState<CauldronScreen> createState() => _CauldronScreenState();
}

class _CauldronScreenState extends ConsumerState<CauldronScreen>
    with WidgetsBindingObserver, LessonSession<CauldronScreen> {
  /// The potion changes colour with every ingredient.
  static const _potions = [
    Color(0xFF7CFF4F),
    Color(0xFFB06CFF),
    Color(0xFFFF9A2E),
    Color(0xFFFF6FB5),
    Color(0xFF3FE0D0),
  ];

  final _rng = math.Random();
  late int _index = myProgress.cauldronResumeIndex;
  late List<ForestWord> _choices = Cauldron.choicesFor(_target, _rng);
  final _shakes = <String, int>{};
  var _found = false;

  /// Whether the child tapped Hear it this round. Nothing plays by itself.
  var _asked = false;
  var _splashes = 0;
  ForestWord? _wrong;

  ForestWord get _target => Cauldron.ingredients[_index];
  bool get _isLast => _index == Cauldron.ingredients.length - 1;

  void _sayTarget() {
    if (!mounted) return;
    setState(() => _asked = true);
    if (audio.muted) {
      setState(() => mutedHint = true);
      return;
    }
    voice.sayWord(_target);
  }

  Future<void> _pick(ForestWord w) async {
    if (_found) return;
    if (w != _target) {
      HapticFeedback.heavyImpact();
      audio.playSfx('audio/woo.mp3');
      // Saying the wrong one's name turns the mistake into a new word.
      if (!audio.muted) voice.sayWord(w);
      setState(() {
        _shakes[w.key] = (_shakes[w.key] ?? 0) + 1;
        _wrong = w;
      });
      return;
    }

    audio.playSfx('audio/chime.mp3');
    setState(() {
      _found = true;
      _wrong = null;
      _splashes++;
    });
    final earned = await earn((p) => p.withIngredientBrewed(w));
    if (earned > 0 && mounted) {
      setState(() {
        burstCoins = earned;
        burstId++;
      });
    }
  }

  void _prev() => stepBack(() {
    _index--;
    _choices = Cauldron.choicesFor(_target, _rng);
    _found = false;
    _asked = false;
    _wrong = null;
  });

  void _next() {
    if (!_isLast) {
      stepForward(() {
        _index++;
        _choices = Cauldron.choicesFor(_target, _rng);
        _found = false;
        _asked = false;
        _wrong = null;
      });
      return;
    }
    finishLesson(
      lesson: Lesson.cauldron,
      message: 'You brewed the magic potion!',
      rule: (p) => p.withPotionBrewed(),
    );
  }

  String get _bubble {
    if (_found) {
      return _isLast ? 'The potion is ready! Tap Finish!' : 'Splash! Tap Next!';
    }
    final wrong = _wrong;
    if (wrong != null) return "Oops! That's the ${wrong.word}. Try again!";
    if (mutedHint) return 'Turn on the sound, or find the ${_target.word}!';
    if (!_asked) return 'Tap Hear it! What does Boo need?';
    return 'Put the ${_target.word} in the cauldron!';
  }

  Widget _potion(double size) => Stack(
    clipBehavior: Clip.none,
    alignment: Alignment.center,
    children: [
      MagicCauldron(
        size: size,
        liquid: _potions[_index % _potions.length],
        splashToken: _splashes,
      ),
      if (burstId > 0)
        Positioned(
          top: size * 0.05,
          left: 0,
          right: 0,
          child: Center(
            child: CoinBurst(key: ValueKey(burstId), amount: burstCoins),
          ),
        ),
    ],
  );

  Widget _orbs(double size) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      for (var i = 0; i < _choices.length; i++)
        IngredientOrb(
          key: ValueKey('$_index-${_choices[i].key}'),
          word: _choices[i],
          size: size,
          index: i,
          dropped: _found && _choices[i] == _target,
          shakeToken: _shakes[_choices[i].key] ?? 0,
          onTap: () => _pick(_choices[i]),
        ),
    ],
  );

  Widget _controls() => LessonNextControls(
    isLast: _isLast,
    // Also open when this ingredient was found before (e.g. after Prev).
    enabled: _found || myProgress.hasBrewed(_target),
    counter: '${_index + 1} / ${Cauldron.ingredients.length}',
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
                        title: Lesson.cauldron.title,
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

  /// Portrait: Boo + bubble + Hear it, the bubbles, the cauldron, Next.
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
      const SizedBox(height: 4),
      _HearButton(onTap: _sayTarget),
      Expanded(
        child: LayoutBuilder(
          builder: (context, box) {
            final orb = math.min(box.maxWidth * 0.26, box.maxHeight * 0.24);
            final pot = math.min(box.maxWidth * 0.8, box.maxHeight - orb - 16);
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_orbs(orb), _potion(math.max(pot, 120))],
            );
          },
        ),
      ),
      const SizedBox(height: 8),
      _controls(),
    ],
  );

  /// Landscape: Boo | bubbles over the cauldron | Next.
  Widget _wideLayout() => Row(
    children: [
      Expanded(
        flex: 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpeechBubble(text: _bubble),
            const FloatingBoo(size: 110),
            _HearButton(onTap: _sayTarget),
          ],
        ),
      ),
      Expanded(
        flex: 5,
        child: LayoutBuilder(
          builder: (context, box) {
            final orb = math.min(box.maxHeight * 0.3, box.maxWidth * 0.22);
            final pot = math.min(box.maxHeight - orb - 8, box.maxWidth * 0.7);
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_orbs(orb), _potion(math.max(pot, 100))],
            );
          },
        ),
      ),
      const SizedBox(width: 12),
      Expanded(flex: 3, child: Center(child: _controls())),
    ],
  );
}

/// Orange "Hear it" pill that repeats the ingredient's name.
class _HearButton extends StatelessWidget {
  const _HearButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Hear it again',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFB04A), HalloweenColors.orange],
            ),
            border: Border.all(color: const Color(0xFFFFE08A), width: 2),
            boxShadow: [
              BoxShadow(
                color: HalloweenColors.orange.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.volume_up_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Hear it',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
