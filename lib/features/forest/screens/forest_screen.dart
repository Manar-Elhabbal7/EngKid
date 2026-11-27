import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:engkids/app/theme.dart';
import 'package:engkids/features/forest/models/forest.dart';
import 'package:engkids/features/forest/models/forest_progress.dart';
import 'package:engkids/features/forest/widgets/forest_card.dart';
import 'package:engkids/features/lessons/lesson_session.dart';
import 'package:engkids/features/lessons/models/lesson.dart';
import 'package:engkids/features/progress/models/child_progress.dart';
import 'package:engkids/features/progress/providers/progress_provider.dart';
import 'package:engkids/shared/widgets/lesson_background.dart';
import 'package:engkids/shared/widgets/lesson_header.dart';
import 'package:engkids/shared/widgets/lesson_stage.dart';

/// Haunted Forest: flip each card to see and hear a new word.
/// The first full listen of a word gives coins; after the last word the
/// lesson is finished, which opens Word Matching.
class ForestScreen extends ConsumerStatefulWidget {
  const ForestScreen({super.key});

  @override
  ConsumerState<ForestScreen> createState() => _ForestScreenState();
}

class _ForestScreenState extends ConsumerState<ForestScreen>
    with WidgetsBindingObserver, LessonSession<ForestScreen> {
  late int _index = myProgress.forestResumeIndex;

  ForestWord get _word => Forest.words[_index];
  bool get _isLast => _index == Forest.words.length - 1;

  Future<void> _hear() {
    final word = _word;
    return listen(
      play: (voice) => voice.sayWord(word),
      reward: () => earn((p) => p.withWordHeard(word)),
    );
  }

  void _prev() => stepBack(() => _index--);

  void _next() {
    if (!_isLast) {
      stepForward(() => _index++);
      return;
    }
    finishLesson(
      lesson: Lesson.forest,
      message: 'You learned all ${Forest.words.length} forest words!',
      rule: (p) => p.withForestFinished(),
    );
  }

  String _bubble(ChildProgress p) {
    if (mutedHint) return 'Turn on the sound to hear me!';
    if (speaking) return 'Listen carefully!';
    if (!p.hasHeardWord(_word)) return 'What is this? Tap the card!';
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
                        title: Lesson.forest.title,
                        coins: p.coins,
                        onBack: () => context.go('/play'),
                      ),
                      Expanded(
                        child: LessonStage(
                          wide: wide,
                          prop: (size) => ForestCard(
                            // New key per word: each card starts face down.
                            key: ValueKey(_word.key),
                            word: _word,
                            size: size,
                            revealed: speaking || p.hasHeardWord(_word),
                            speaking: speaking,
                            onTap: _hear,
                          ),
                          number: _index + 1,
                          total: Forest.words.length,
                          bubble: _bubble(p),
                          heard: p.hasHeardWord(_word),
                          isLast: _isLast,
                          burstId: burstId,
                          burstCoins: burstCoins,
                          onNext: _next,
                          onPrev: _index > 0 ? _prev : null,
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
