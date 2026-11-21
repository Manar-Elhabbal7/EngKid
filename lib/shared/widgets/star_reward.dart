import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';

/// A golden star that bursts into view when the child earns a reward.
///
/// Wrap in an [AnimatedSwitcher] or trigger [key] changes to replay.
class StarReward extends StatelessWidget {
  const StarReward({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow ring
        Container(
          width: size * 1.4,
          height: size * 1.4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: HalloweenColors.starGold.withValues(alpha: 0.5),
                blurRadius: 24,
                spreadRadius: 6,
              ),
            ],
          ),
        ),
        // Star
        Text('⭐', style: TextStyle(fontSize: size))
            .animate()
            .scaleXY(begin: 0, end: 1, duration: 400.ms, curve: Curves.elasticOut)
            .rotate(begin: -0.3, end: 0, duration: 400.ms)
            .then()
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(begin: 1.0, end: 1.1, duration: 800.ms, curve: Curves.easeInOut),
        // Sparkle particles
        ..._sparkles(size),
      ],
    );
  }

  List<Widget> _sparkles(double starSize) {
    const positions = [
      Offset(-1, -1),
      Offset(1, -1),
      Offset(-1, 1),
      Offset(1, 1),
      Offset(0, -1.4),
      Offset(0, 1.4),
    ];
    return positions.indexed.map((entry) {
      final (i, offset) = entry;
      return Positioned(
        left: (starSize * 0.7) + offset.dx * starSize * 0.65,
        top: (starSize * 0.7) + offset.dy * starSize * 0.65,
        child: Text('✨', style: TextStyle(fontSize: starSize * 0.28))
            .animate(delay: Duration(milliseconds: 80 * i))
            .fadeIn(duration: 300.ms)
            .scaleXY(begin: 0, end: 1, duration: 300.ms)
            .then(delay: 400.ms)
            .fadeOut(duration: 300.ms),
      );
    }).toList();
  }
}
