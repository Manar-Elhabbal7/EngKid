import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:engkids/app/theme.dart';
import 'package:engkids/features/home/widgets/menu_pill_button.dart';

/// Round Prev button beside the green Next / Finish button, with the
/// "1 / 26" counter under them.
/// Next stays dimmed and untappable until [enabled]; Prev is dimmed when
/// [onPrev] is null (on the first item).
class LessonNextControls extends StatelessWidget {
  const LessonNextControls({
    super.key,
    required this.isLast,
    required this.enabled,
    required this.counter,
    required this.onNext,
    this.onPrev,
  });

  final bool isLast;
  final bool enabled;

  /// e.g. "1 / 26" or "Round 2 / 5".
  final String counter;
  final VoidCallback onNext;

  /// Goes back one item; null on the first item.
  final VoidCallback? onPrev;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PrevButton(onTap: onPrev),
            const SizedBox(width: 10),
            Flexible(
              child: MenuPillButton(
                label: isLast ? 'Finish' : 'Next',
                icon: isLast
                    ? Icons.emoji_events_rounded
                    : Icons.arrow_forward_rounded,
                fill: HalloweenColors.playGreen,
                shadow: HalloweenColors.playGreenDark,
                foreground: Colors.white,
                fontSize: 26,
                onPressed: enabled ? onNext : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          counter,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: HalloweenColors.cream,
            fontSize: 18,
            shadows: const [Shadow(color: Color(0xCC1A0030), blurRadius: 6)],
          ),
        ),
      ],
    );
  }
}

/// Purple round "back one step" button with a gold rim.
class _PrevButton extends StatelessWidget {
  const _PrevButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Tooltip(
      message: 'Previous',
      child: Semantics(
        button: true,
        enabled: enabled,
        label: 'Previous',
        excludeSemantics: true,
        child: GestureDetector(
          onTap: enabled
              ? () {
                  HapticFeedback.lightImpact();
                  onTap!();
                }
              : null,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: enabled ? 1 : 0.4,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF6A3FB0), HalloweenColors.castlePurple],
                ),
                border: Border.all(color: const Color(0xFFE8C27A), width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x88000000),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: HalloweenColors.cream,
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
