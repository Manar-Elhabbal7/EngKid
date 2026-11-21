import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';

/// A large rounded button with a pumpkin-orange glow that pulses gently.
/// Triggers [HapticFeedback.lightImpact] on press.
///
/// Minimum tap target is 56 dp tall (exceeds the 48 dp a11y minimum).
class SpookyButton extends StatelessWidget {
  const SpookyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
    this.width,
  });

  final String label;
  final VoidCallback onPressed;
  final Widget? icon;
  final Color? color;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? HalloweenColors.pumpkinOrange;

    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: bg.withValues(alpha: 0.55),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: HalloweenColors.ghostWhite,
            minimumSize: Size(width ?? 120, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: HalloweenColors.ghostWhite,
                ),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          child: icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon!,
                    const SizedBox(width: 8),
                    Text(label),
                  ],
                )
              : Text(label),
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(
            begin: 1.0,
            end: 1.03,
            duration: 1200.ms,
            curve: Curves.easeInOut,
          ),
    );
  }
}
