import 'package:flutter/material.dart';
import 'package:engkids/features/alphabet/widgets/coin_counter.dart';

/// "+5" with a coin that rises and fades. Give it a new [key] each time
/// coins are earned so the animation plays again.
class CoinBurst extends StatelessWidget {
  const CoinBurst({super.key, required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1400),
        curve: Curves.easeOut,
        builder: (context, t, child) => Opacity(
          // clamp: at t == 1 the maths gives a tiny negative number,
          // which Opacity rejects (that showed as a red error box).
          opacity: (t < 0.7 ? 1.0 : 1 - (t - 0.7) / 0.3).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, -70 * t),
            child: Transform.scale(scale: 0.6 + 0.5 * t, child: child),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CoinImage(size: 40),
            const SizedBox(width: 6),
            Text(
              '+$amount',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xFFFFE27A),
                fontSize: 36,
                shadows: const [
                  Shadow(color: Color(0xFF7A3A00), blurRadius: 6),
                  Shadow(color: Color(0xFF7A3A00), offset: Offset(0, 2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
