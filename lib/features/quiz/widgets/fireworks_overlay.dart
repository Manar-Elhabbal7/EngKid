import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme.dart';

/// A full-screen burst of colourful firework particles.
/// Shown on a 5-in-a-row correct streak.
/// [key] should change each time you want to replay the animation.
class FireworksOverlay extends StatelessWidget {
  const FireworksOverlay({super.key});

  static const _colors = [
    HalloweenColors.pumpkinOrange,
    HalloweenColors.pumpkinYellow,
    HalloweenColors.spookyGreen,
    HalloweenColors.ghostWhite,
    Color(0xFFFF69B4),
    Color(0xFF00BFFF),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final rng = Random(42);

    return IgnorePointer(
      child: Stack(
        children: [
          // Semi-transparent flash
          Container(color: Colors.white.withValues(alpha: 0.08))
              .animate()
              .fadeIn(duration: 100.ms)
              .then()
              .fadeOut(duration: 400.ms),

          // Streak label
          Positioned(
            top: size.height * 0.18,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: HalloweenColors.pumpkinOrange,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: HalloweenColors.pumpkinOrange.withValues(alpha: 0.6),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Text(
                  '🔥 5 in a row! Amazing!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              )
                  .animate()
                  .scaleXY(begin: 0.5, end: 1.0, duration: 500.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 300.ms),
            ),
          ),

          // Particles
          ...List.generate(40, (i) {
            final x = rng.nextDouble() * size.width;
            final y = rng.nextDouble() * size.height * 0.7;
            final color = _colors[i % _colors.length];
            final particleSize = 8.0 + rng.nextDouble() * 10;
            final delay = Duration(milliseconds: rng.nextInt(600));

            return Positioned(
              left: x,
              top: y,
              child: Container(
                width: particleSize,
                height: particleSize,
                decoration: BoxDecoration(
                  color: color,
                  shape: rng.nextBool() ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius:
                      rng.nextBool() ? BorderRadius.circular(2) : null,
                ),
              )
                  .animate(delay: delay)
                  .fadeIn(duration: 200.ms)
                  .moveY(
                    begin: 0,
                    end: -(30 + rng.nextDouble() * 60),
                    duration: Duration(milliseconds: 600 + rng.nextInt(400)),
                    curve: Curves.easeOut,
                  )
                  .scaleXY(begin: 1.0, end: 0.0, duration: 800.ms)
                  .fadeOut(duration: 400.ms, delay: 400.ms),
            );
          }),
        ],
      ),
    );
  }
}
