import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:engkids/app/theme.dart';
import 'package:engkids/features/alphabet/models/alphabet.dart';
import 'package:engkids/features/alphabet/models/alphabet_progress.dart';
import 'package:engkids/features/alphabet/widgets/letter_pumpkin.dart';
import 'package:engkids/features/lessons/lesson_session.dart';
import 'package:engkids/features/lessons/models/lesson.dart';
import 'package:engkids/features/progress/models/child_progress.dart';
import 'package:engkids/features/progress/providers/progress_provider.dart';
import 'package:engkids/shared/widgets/lesson_background.dart';
import 'package:engkids/shared/widgets/lesson_header.dart';
import 'package:engkids/shared/widgets/lesson_stage.dart';

/// Alphabet Adventure: tap the pumpkin to hear each letter A–Z.
/// The first full listen of a letter gives coins; after Z the lesson is
/// finished, which opens Haunted Forest.
class AlphabetScreen extends ConsumerStatefulWidget {
  const AlphabetScreen({super.key});

  @override
  ConsumerState<AlphabetScreen> createState() => _AlphabetScreenState();
}

class _AlphabetScreenState extends ConsumerState<AlphabetScreen>
    with WidgetsBindingObserver, LessonSession<AlphabetScreen> {
  late int _index = myProgress.alphabetResumeIndex;

  AlphabetLetter get _letter => Alphabet.letters[_index];
  bool get _isLast => _index == Alphabet.letters.length - 1;

  Future<void> _hear() {
    final letter = _letter;
    return listen(
      play: (voice) => voice.say(letter),
      reward: () => earn((p) => p.withLetterHeard(letter)),
    );
  }

  void _next() {
    if (!_isLast) {
      stepForward(() => _index++);
      return;
    }
    finishLesson(
      lesson: Lesson.alphabet,
      message: 'You learned all 26 letters!',
      rule: (p) => p.withAlphabetFinished(),
    );
  }

  String _bubble(ChildProgress p) {
    if (mutedHint) return 'Turn on the sound to hear me!';
    if (speaking) return 'Listen carefully!';
    if (!p.hasHeard(_letter)) return 'Tap the pumpkin to hear the letter!';
    return _isLast ? 'You did it! Tap Finish!' : 'Great job! Tap Next!';
  }

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
                        title: Lesson.alphabet.title,
                        coins: p.coins,
                        onBack: () => context.go('/play'),
                      ),
                      Expanded(
                        child: LessonStage(
                          wide: wide,
                          prop: (size) => LetterPumpkin(
                            letter: _letter,
                            size: size,
                            speaking: speaking,
                            onTap: _hear,
                          ),
                          number: _index + 1,
                          total: Alphabet.letters.length,
                          bubble: _bubble(p),
                          heard: p.hasHeard(_letter),
                          isLast: _isLast,
                          burstId: burstId,
                          burstCoins: burstCoins,
                          onNext: _next,
                        ),
                      ),
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
}
