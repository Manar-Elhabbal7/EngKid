import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme.dart';
import '../models/matching_game.dart';

/// A draggable emoji tile the child picks up and drops onto a [WordSlot].
///
/// Disappears (fades out) once [isMatched] is true.
class EmojiTile extends StatelessWidget {
  const EmojiTile({
    super.key,
    required this.pair,
    required this.isMatched,
    required this.isWrong,
  });

  final MatchPair pair;
  final bool isMatched;
  final bool isWrong;

  @override
  Widget build(BuildContext context) {
    if (isMatched) {
      return const SizedBox(width: 72, height: 72);
    }

    return Draggable<String>(
      data: pair.id,
      feedback: _TileBody(
        emoji: pair.emoji,
        isWrong: false,
        isDragging: true,
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _TileBody(emoji: pair.emoji, isWrong: false),
      ),
      child: _TileBody(emoji: pair.emoji, isWrong: isWrong)
          .animate(
            target: isWrong ? 1 : 0,
          )
          .shakeX(hz: 6, amount: 6, duration: 400.ms),
    );
  }
}

class _TileBody extends StatelessWidget {
  const _TileBody({
    required this.emoji,
    required this.isWrong,
    this.isDragging = false,
  });

  final String emoji;
  final bool isWrong;
  final bool isDragging;

  @override
  Widget build(BuildContext context) {
    final border = isWrong
        ? HalloweenColors.pumpkinOrange
        : HalloweenColors.ghostWhite.withValues(alpha: 0.5);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: HalloweenColors.midPurple.withValues(alpha: isDragging ? 0.95 : 0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 2),
          boxShadow: isDragging
              ? [
                  BoxShadow(
                    color: HalloweenColors.pumpkinOrange.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 4,
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 36)),
        ),
      ),
    );
  }
}
