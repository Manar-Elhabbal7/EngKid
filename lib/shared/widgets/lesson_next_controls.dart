import 'package:flutter/material.dart';
import 'package:engkids/app/theme.dart';
import 'package:engkids/features/home/widgets/menu_pill_button.dart';

/// Green Next / Finish button with the "1 / 26" counter under it.
/// The button stays dimmed and untappable until [enabled].
class LessonNextControls extends StatelessWidget {
  const LessonNextControls({
    super.key,
    required this.isLast,
    required this.enabled,
    required this.counter,
    required this.onNext,
  });

  final bool isLast;
  final bool enabled;

  /// e.g. "1 / 26" or "Round 2 / 5".
  final String counter;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MenuPillButton(
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
