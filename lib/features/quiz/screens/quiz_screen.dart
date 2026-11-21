import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/services/audio_service.dart';
import '../../../shared/services/tts_service.dart';
import '../../../shared/providers/progress_provider.dart';
import '../../../shared/widgets/ghost_mascot.dart';
import '../../../shared/widgets/scaffold_with_background.dart';
import '../../../shared/widgets/spooky_button.dart';
import '../../../shared/widgets/star_reward.dart';
import '../models/quiz_engine.dart';
import '../widgets/answer_button.dart';
import '../widgets/fireworks_overlay.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late QuizEngine _engine;

  /// Which choice was tapped this question (null = not answered yet).
  String? _selected;

  /// True for 1.2 s after answering, so the child sees the result.
  bool _revealing = false;

  /// True while the fireworks overlay is visible.
  bool _showFireworks = false;

  /// Key to re-trigger the fireworks animation on each streak.
  int _fireworksKey = 0;

  GhostExpression _expression = GhostExpression.happy;

  @override
  void initState() {
    super.initState();
    _engine = QuizEngine();
  }

  // ── Answer handler ────────────────────────────────────────────────────────

  Future<void> _onAnswer(String choice) async {
    if (_revealing) return;
    setState(() {
      _selected = choice;
      _revealing = true;
    });

    final result = _engine.submit(choice);

    if (result == AnswerResult.correct) {
      await AudioService.instance.play(SfxType.chime);
      setState(() => _expression = GhostExpression.excited);

      // Fireworks on 5-in-a-row streak.
      if (_engine.streak > 0 && _engine.streak % 5 == 0) {
        await AudioService.instance.play(SfxType.sparkle);
        setState(() {
          _showFireworks = true;
          _fireworksKey++;
        });
        await Future<void>.delayed(const Duration(milliseconds: 1800));
        if (mounted) setState(() => _showFireworks = false);
      }

      // Award a star every 5 correct answers.
      if (_engine.score > 0 && _engine.score % 5 == 0) {
        ref.read(totalStarsProvider.notifier).increment();
      }
    } else {
      await AudioService.instance.play(SfxType.woo);
      setState(() => _expression = GhostExpression.sad);
      // Speak the correct answer so the child hears the right word.
      await TtsService.instance.speak(_engine.current.answer);
    }

    // Pause to let the child read the result.
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() {
        _selected = null;
        _revealing = false;
        _expression = GhostExpression.happy;
      });
    }
  }

  void _restart() => setState(() {
        _engine = QuizEngine();
        _selected = null;
        _revealing = false;
        _showFireworks = false;
        _expression = GhostExpression.happy;
      });

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_engine.isFinished) {
      return _SummaryScreen(
        score: _engine.score,
        total: _engine.totalQuestions,
        maxStreak: _engine.maxStreak,
        onReplay: _restart,
        onHome: () => context.go('/'),
      );
    }

    return ScaffoldWithBackground(
      child: Stack(
        children: [
          OrientationBuilder(
            builder: (context, orientation) =>
                orientation == Orientation.portrait
                    ? _buildPortrait()
                    : _buildLandscape(),
          ),
          if (_showFireworks)
            FireworksOverlay(key: ValueKey(_fireworksKey)),
        ],
      ),
    );
  }

  // ── Portrait ──────────────────────────────────────────────────────────────

  Widget _buildPortrait() {
    return Column(
      children: [
        _TopBar(engine: _engine),
        const SizedBox(height: 8),
        _EmojiPrompt(
          emoji: _engine.current.emoji,
          questionNumber: _engine.answered + 1,
          total: _engine.totalQuestions,
        ),
        const SizedBox(height: 16),
        _StreakBadge(streak: _engine.streak),
        const SizedBox(height: 10),
        Expanded(child: _AnswerGrid(
          question: _engine.current,
          selected: _selected,
          onAnswer: _onAnswer,
          disabled: _revealing,
        )),
        _BooBar(expression: _expression, selected: _selected,
            correct: _engine.isFinished ? null : _engine.current.answer),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Landscape ─────────────────────────────────────────────────────────────

  Widget _buildLandscape() {
    return Row(
      children: [
        // Left: emoji + Boo
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _EmojiPrompt(
                  emoji: _engine.current.emoji,
                  questionNumber: _engine.answered + 1,
                  total: _engine.totalQuestions,
                  compact: true,
                ),
                const SizedBox(height: 12),
                _StreakBadge(streak: _engine.streak),
                const SizedBox(height: 8),
                GhostMascot(expression: _expression, size: 56),
              ],
            ),
          ),
        ),
        // Right: answers
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 16, 12),
            child: Column(
              children: [
                _TopBar(engine: _engine, compact: true),
                const SizedBox(height: 8),
                Expanded(child: _AnswerGrid(
                  question: _engine.current,
                  selected: _selected,
                  onAnswer: _onAnswer,
                  disabled: _revealing,
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.engine, this.compact = false});
  final QuizEngine engine;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          if (!compact)
            Text(
              '❓ Spell-It Quiz',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: HalloweenColors.pumpkinYellow,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          const Spacer(),
          _ScoreChip(score: engine.score, total: engine.totalQuestions),
        ],
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.score, required this.total});
  final int score;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: HalloweenColors.pumpkinOrange.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HalloweenColors.pumpkinOrange, width: 1.5),
      ),
      child: Text(
        '⭐ $score / $total',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: HalloweenColors.pumpkinOrange,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _EmojiPrompt extends StatelessWidget {
  const _EmojiPrompt({
    required this.emoji,
    required this.questionNumber,
    required this.total,
    this.compact = false,
  });
  final String emoji;
  final int questionNumber;
  final int total;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                HalloweenColors.midPurple,
                HalloweenColors.deepPurple,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: HalloweenColors.pumpkinOrange,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: HalloweenColors.pumpkinOrange.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            emoji,
            style: TextStyle(fontSize: compact ? 56 : 80),
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms)
            .scaleXY(begin: 0.8, end: 1.0, duration: 400.ms, curve: Curves.elasticOut),
        const SizedBox(height: 8),
        Text(
          'Question $questionNumber of $total',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: HalloweenColors.ghostWhite.withValues(alpha: 0.65),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'What is this? 👆',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: HalloweenColors.ghostWhite,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    if (streak < 2) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: HalloweenColors.pumpkinYellow.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: HalloweenColors.pumpkinYellow,
          width: 1.5,
        ),
      ),
      child: Text(
        '🔥 $streak in a row!',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: HalloweenColors.pumpkinYellow,
              fontWeight: FontWeight.bold,
            ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scaleXY(begin: 0.85, end: 1.0, duration: 300.ms, curve: Curves.elasticOut);
  }
}

class _AnswerGrid extends StatelessWidget {
  const _AnswerGrid({
    required this.question,
    required this.selected,
    required this.onAnswer,
    required this.disabled,
  });
  final QuizQuestion question;
  final String? selected;
  final void Function(String) onAnswer;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: question.choices.indexed.map((entry) {
          final (i, choice) = entry;
          final AnswerState state;
          if (selected == null) {
            state = AnswerState.idle;
          } else if (choice == question.answer) {
            state = AnswerState.correct;
          } else if (choice == selected) {
            state = AnswerState.wrong;
          } else {
            state = AnswerState.idle;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: AnswerButton(
              key: ValueKey('${question.answer}_$choice'),
              label: choice,
              onTap: () => onAnswer(choice),
              state: state,
              disabled: disabled,
              index: i,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BooBar extends StatelessWidget {
  const _BooBar({
    required this.expression,
    required this.selected,
    required this.correct,
  });
  final GhostExpression expression;
  final String? selected;
  final String? correct;

  @override
  Widget build(BuildContext context) {
    final String label;
    if (selected == null) {
      label = 'Pick the right word! 🎃';
    } else if (selected == correct) {
      label = 'Correct! Great job! 🌟';
    } else {
      label = 'The answer is "$correct" 👂';
    }
    return GhostMascot(expression: expression, size: 52, label: label);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary screen
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryScreen extends StatelessWidget {
  const _SummaryScreen({
    required this.score,
    required this.total,
    required this.maxStreak,
    required this.onReplay,
    required this.onHome,
  });
  final int score;
  final int total;
  final int maxStreak;
  final VoidCallback onReplay;
  final VoidCallback onHome;

  String get _grade {
    final pct = score / total;
    if (pct >= 0.9) return 'Outstanding! 🏆';
    if (pct >= 0.7) return 'Great job! 🌟';
    if (pct >= 0.5) return 'Good try! 👍';
    return 'Keep practising! 💪';
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const StarReward(size: 80),
              const SizedBox(height: 20),
              Text(
                _grade,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: HalloweenColors.pumpkinYellow,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _StatRow(label: '✅ Correct', value: '$score / $total'),
              const SizedBox(height: 8),
              _StatRow(label: '🔥 Best streak', value: '$maxStreak'),
              const SizedBox(height: 32),
              const GhostMascot(
                expression: GhostExpression.excited,
                size: 72,
                label: 'You are amazing! 🎃',
              ),
              const SizedBox(height: 32),
              SpookyButton(
                label: 'Play Again 🔄',
                onPressed: onReplay,
                width: 220,
              ),
              const SizedBox(height: 14),
              SpookyButton(
                label: '🏚️ Go Home',
                onPressed: onHome,
                color: HalloweenColors.midPurple,
                width: 220,
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.2, end: 0, duration: 500.ms),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: HalloweenColors.midPurple.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: HalloweenColors.pumpkinOrange.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: HalloweenColors.ghostWhite,
                  )),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: HalloweenColors.pumpkinYellow,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
