import 'package:flutter/material.dart';
import 'package:engkids/app/theme.dart';

class CoinImage extends StatelessWidget {
  const CoinImage({super.key, required this.size});

  static const image = 'assets/images/coin.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      image,
      width: size,
      height: size,
      cacheWidth: 160,
      excludeFromSemantics: true,
    );
  }
}

/// Coin pill for the top-right corner. The number pops when it changes.
class CoinCounter extends StatelessWidget {
  const CoinCounter({super.key, required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$coins coins',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.fromLTRB(6, 4, 14, 4),
        decoration: BoxDecoration(
          color: const Color(0xCC2A1450),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFE8C27A), width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CoinImage(size: 34),
            const SizedBox(width: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: Tween(begin: 1.6, end: 1.0).animate(anim),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Text(
                '$coins',
                key: ValueKey(coins),
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(color: HalloweenColors.cream, fontSize: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
