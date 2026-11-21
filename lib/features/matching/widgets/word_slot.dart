import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme.dart';
import '../models/matching_game.dart';

/// A [DragTarget] word slot. Accepts an emoji tile whose id matches [pair.id].
///
/// Shows a sparkle burst when matched, a shake when wrong.
class WordSlot extends StatelessWidget {
  const WordSlot({
    super.key,
    required this.pair,
    required this.isMatched,
    required this.isWrong,
    required this.onAccept,
    required this.onWrongDrop,
  });

  final MatchPair pair;
  final bool isMatched;
  final bool isWrong;
  final VoidCallback onAccept;
  final VoidCallback onWrongDrop;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => !isMatched,
      onAcceptWithDetails: (details) {
        if (details.data == pair.id) {
          onAccept();
        } else {
          onWrongDrop();
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return _SlotBody(
          pair: pair,
          isMatched: isMatched,
          isWrong: isWrong,
          isHovering: isHovering,
        );
      },
    );
  }
}

class _SlotBody extends StatelessWidget {
  const _SlotBody({
    required this.pair,
    required this.isMatched,
    required this.isWrong,
    required this.isHovering,
  });

  final MatchPair pair;
  final bool isMatched;
  final bool isWrong;
  final bool isHovering;

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color bgColor;

    if (isMatched) {
      borderColor = HalloweenColors.spookyGreen;
      bgColor = HalloweenColors.spookyGreen.withValues(alpha: 0.2);
    } else if (isWrong) {
      borderColor = HalloweenColors.pumpkinOrange;
      bgColor = HalloweenColors.pumpkinOrange.withValues(alpha: 0.15);
    } else if (isHovering) {
      borderColor = HalloweenColors.pumpkinYellow;
      bgColor = HalloweenColors.pumpkinYellow.withValues(alpha: 0.15);
    } else {
      borderColor = HalloweenColors.ghostWhite.withValues(alpha: 0.3);
      bgColor = HalloweenColors.midPurple.withValues(alpha: 0.6);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isMatched) ...[
            const Text('✅', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
          ],
          Text(
            pair.word,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isMatched
                      ? HalloweenColors.spookyGreen
                      : HalloweenColors.ghostWhite,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    )
        .animate(target: isMatched ? 1 : 0)
        .scaleXY(begin: 1.0, end: 1.06, duration: 300.ms, curve: Curves.elasticOut)
        .animate(target: isWrong ? 1 : 0)
        .shakeX(hz: 6, amount: 5, duration: 400.ms);
  }
}
