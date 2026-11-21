import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme.dart';

/// State of an answer button during the reveal phase.
enum AnswerState { idle, correct, wrong }

/// A large tappable answer choice button.
///
/// When [state] changes to [AnswerState.correct] it pulses green.
/// When [state] changes to [AnswerState.wrong] it shakes red-orange.
/// While [disabled], taps are ignored.
class AnswerButton extends StatelessWidget {
  const AnswerButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.state,
    required this.disabled,
    required this.index,
  });

  final String label;
  final VoidCallback onTap;
  final AnswerState state;
  final bool disabled;

  /// Used to stagger entrance animations.
  final int index;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color textColor;

    switch (state) {
      case AnswerState.correct:
        bg = HalloweenColors.spookyGreen.withValues(alpha: 0.25);
        border = HalloweenColors.spookyGreen;
        textColor = HalloweenColors.spookyGreen;
      case AnswerState.wrong:
        bg = HalloweenColors.pumpkinOrange.withValues(alpha: 0.2);
        border = HalloweenColors.pumpkinOrange;
        textColor = HalloweenColors.pumpkinOrange;
      case AnswerState.idle:
        bg = HalloweenColors.midPurple.withValues(alpha: 0.85);
        border = HalloweenColors.ghostWhite.withValues(alpha: 0.35);
        textColor = HalloweenColors.ghostWhite;
    }

    return GestureDetector(
      onTap: disabled ? null : () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border, width: 2.2),
          boxShadow: state == AnswerState.correct
              ? [
                  BoxShadow(
                    color: HalloweenColors.spookyGreen.withValues(alpha: 0.4),
                    blurRadius: 14,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            _StateIcon(state: state),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      )
          // Wrong answer shake
          .animate(target: state == AnswerState.wrong ? 1 : 0)
          .shakeX(hz: 6, amount: 6, duration: 400.ms)
          // Correct answer scale pulse
          .animate(target: state == AnswerState.correct ? 1 : 0)
          .scaleXY(begin: 1.0, end: 1.04, duration: 300.ms, curve: Curves.elasticOut)
          // Entrance stagger
          .animate(delay: Duration(milliseconds: 80 * index))
          .fadeIn(duration: 300.ms)
          .slideX(begin: 0.15, end: 0, duration: 300.ms),
    );
  }
}

class _StateIcon extends StatelessWidget {
  const _StateIcon({required this.state});
  final AnswerState state;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      AnswerState.correct => const Text('✅', style: TextStyle(fontSize: 20)),
      AnswerState.wrong   => const Text('❌', style: TextStyle(fontSize: 20)),
      AnswerState.idle    => const Text('🎃', style: TextStyle(fontSize: 20)),
    };
  }
}
