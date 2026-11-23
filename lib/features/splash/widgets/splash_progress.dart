import 'package:flutter/material.dart';
import 'package:engkids/app/theme.dart';

/// "Boo is waking up..." label above a wooden-rimmed bar whose left end is
/// capped by the glowing pumpkin from `assets/images/progress_pumpkin.jpg`.
class SplashProgress extends StatelessWidget {
  const SplashProgress({super.key, required this.value, required this.bob});

  /// Fill amount, 0.0 – 1.0.
  final double value;

  /// Vertical offset for the pumpkin's gentle bounce.
  final double bob;

  static const _pumpkinSize = 54.0;
  static const _barHeight = 24.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Boo is waking up',
      value: '${(value * 100).round()} percent',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Boo is waking up...',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: HalloweenColors.cream,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              shadows: const [
                Shadow(
                  color: Color(0xCC1A0030),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: _pumpkinSize,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                // Bar starts under the pumpkin's centre so the pumpkin caps it.
                Padding(
                  padding: const EdgeInsets.only(left: _pumpkinSize / 2),
                  child: _GlowBar(value: value, height: _barHeight),
                ),
                Transform.translate(
                  offset: Offset(0, bob),
                  child: const _PumpkinBadge(size: _pumpkinSize),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PumpkinBadge extends StatelessWidget {
  const _PumpkinBadge({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: HalloweenColors.orange.withValues(alpha: 0.7),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipOval(
        // The source image has a purple margin; zoom in so only the
        // pumpkin shows inside the circle.
        child: Transform.scale(
          scale: 1.35,
          child: Image.asset(
            'assets/images/progress_pumpkin.jpg',
            fit: BoxFit.cover,
            semanticLabel: 'Pumpkin',
          ),
        ),
      ),
    );
  }
}

class _GlowBar extends StatelessWidget {
  const _GlowBar({required this.value, required this.height});

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(height);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: HalloweenColors.barTrack,
        borderRadius: radius,
        // Dark wood rim, like the sign on the scene.
        border: Border.all(color: const Color(0xFF5A3418), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFC46B), Color(0xFFFF8A1A)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: HalloweenColors.orange.withValues(alpha: 0.6),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
