import 'package:flutter/material.dart';
import 'package:engkids/app/theme.dart';

class SplashProgress extends StatelessWidget {
  const SplashProgress({super.key, required this.value, required this.bob});

  final double value;
  final double bob;

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
              fontSize: 22,
              letterSpacing: 0.2,
              shadows: const [
                Shadow(
                  color: Color(0xAA1A0030),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Transform.translate(
                offset: Offset(0, bob),
                child: const _PumpkinBadge(),
              ),
              const SizedBox(width: 10),
              Expanded(child: _GlowBar(value: value)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PumpkinBadge extends StatelessWidget {
  const _PumpkinBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: HalloweenColors.orange.withValues(alpha: 0.55),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/progress_pumpkin.jpg',
          fit: BoxFit.cover,
          semanticLabel: 'Pumpkin',
        ),
      ),
    );
  }
}

class _GlowBar extends StatelessWidget {
  const _GlowBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      decoration: BoxDecoration(
        color: HalloweenColors.barTrack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x66FFB347), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: HalloweenColors.orange.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                const ColoredBox(
                  color: HalloweenColors.barTrack,
                  child: SizedBox.expand(),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: constraints.maxWidth * value.clamp(0.0, 1.0),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFF6B00),
                          Color(0xFFFFB347),
                          Color(0xFFFFD56A),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
