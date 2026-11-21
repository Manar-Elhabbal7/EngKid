import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Which emotion Boo the ghost is expressing.
enum GhostExpression {
  happy,
  sad,
  thinking,
  excited,
  waving,
}

/// "Boo" — the friendly ghost mascot that appears on every screen.
///
/// Pass [expression] to change his face. He always floats gently.
/// [size] controls the font size of the emoji rendering.
class GhostMascot extends StatelessWidget {
  const GhostMascot({
    super.key,
    this.expression = GhostExpression.happy,
    this.size = 80,
    this.label,
  });

  final GhostExpression expression;
  final double size;

  /// Optional speech-bubble text shown below Boo.
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _BooEmoji(expression: expression, size: size),
        if (label != null) ...[
          const SizedBox(height: 6),
          _SpeechBubble(text: label!),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _BooEmoji extends StatelessWidget {
  const _BooEmoji({required this.expression, required this.size});

  final GhostExpression expression;
  final double size;

  String get _emoji {
    return switch (expression) {
      GhostExpression.happy => '😄',
      GhostExpression.sad => '😢',
      GhostExpression.thinking => '🤔',
      GhostExpression.excited => '🤩',
      GhostExpression.waving => '👋',
    };
  }

  @override
  Widget build(BuildContext context) {
    // Ghost body + expression overlay
    return Stack(
      alignment: Alignment.center,
      children: [
        Text('👻', style: TextStyle(fontSize: size))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(
              begin: 0,
              end: -10,
              duration: 1600.ms,
              curve: Curves.easeInOut,
            ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Text(_emoji, style: TextStyle(fontSize: size * 0.45)),
        ),
      ],
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF1A0030),
              fontWeight: FontWeight.w600,
            ),
        textAlign: TextAlign.center,
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scaleXY(begin: 0.85, end: 1.0, duration: 300.ms);
  }
}
