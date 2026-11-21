import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme.dart';

/// An animated cauldron made of emoji + floating bubble particles.
/// The whole thing bobs gently and emits rising bubble dots.
class BubblingCauldron extends StatelessWidget {
  const BubblingCauldron({super.key, this.size = 100});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.4,
      height: size * 1.6,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Rising bubble particles
          ..._bubbles(size),

          // Cauldron body — bobs up and down
          Text('🫧', style: TextStyle(fontSize: size * 0.45))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: -4, end: 0, duration: 700.ms, curve: Curves.easeInOut),

          Positioned(
            bottom: 0,
            child: Text('🪄', style: TextStyle(fontSize: size * 1.0))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: -6, duration: 1800.ms, curve: Curves.easeInOut),
          ),
        ],
      ),
    );
  }

  List<Widget> _bubbles(double cauldronSize) {
    final offsets = [0.2, 0.5, 0.75, 0.35, 0.65];
    final delays  = [0,   300, 600,  150,  450 ];
    return List.generate(offsets.length, (i) {
      return Positioned(
        left: cauldronSize * 1.4 * offsets[i],
        bottom: cauldronSize * 0.7,
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: HalloweenColors.spookyGreen.withValues(alpha: 0.55),
          ),
        )
            .animate(
              onPlay: (c) => c.repeat(),
              delay: Duration(milliseconds: delays[i]),
            )
            .moveY(begin: 0, end: -(cauldronSize * 0.6), duration: 1200.ms)
            .fadeOut(duration: 600.ms, delay: 600.ms)
            .scaleXY(begin: 1.0, end: 0.3, duration: 1200.ms),
      );
    });
  }
}

/// An animated progress bar with a glowing fill.
class HalloweenProgressBar extends StatelessWidget {
  const HalloweenProgressBar({
    super.key,
    required this.label,
    required this.value,       // 0.0 – 1.0
    required this.current,
    required this.total,
    required this.color,
    required this.emoji,
  });

  final String label;
  final double value;
  final int current;
  final int total;
  final Color color;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HalloweenColors.ghostWhite,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            Text(
              '$current / $total',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              // Track
              Container(
                height: 14,
                width: double.infinity,
                color: HalloweenColors.midPurple,
              ),
              // Fill
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                height: 14,
                width: double.infinity,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: value.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withValues(alpha: 0.7), color],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
