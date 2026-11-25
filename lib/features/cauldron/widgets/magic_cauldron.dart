import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The cauldron picture with living effects on top: a glow behind it in the
/// potion colour [liquid], bubbles on the surface, and a splash plus a
/// little "gulp" bounce each time [splashToken] changes.
class MagicCauldron extends StatefulWidget {
  const MagicCauldron({
    super.key,
    required this.size,
    required this.liquid,
    required this.splashToken,
  });

  static const image = 'assets/images/cauldron.png';

  final double size;
  final Color liquid;
  final int splashToken;

  @override
  State<MagicCauldron> createState() => _MagicCauldronState();
}

class _MagicCauldronState extends State<MagicCauldron>
    with TickerProviderStateMixin {
  late final AnimationController _bubble = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();
  late final AnimationController _splash = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void didUpdateWidget(MagicCauldron old) {
    super.didUpdateWidget(old);
    if (widget.splashToken != old.splashToken) _splash.forward(from: 0);
  }

  @override
  void dispose() {
    _bubble.dispose();
    _splash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return Semantics(
      label: 'Magic cauldron',
      excludeSemantics: true,
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: widget.liquid),
        duration: const Duration(milliseconds: 600),
        builder: (context, color, _) {
          final liquid = color ?? widget.liquid;
          return AnimatedBuilder(
            animation: Listenable.merge([_bubble, _splash]),
            builder: (context, _) {
              final splash = _splash.isAnimating ? _splash.value : 0.0;
              final gulp = 1 + 0.06 * math.sin(splash * math.pi);
              return SizedBox.square(
                dimension: size,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Glow in the potion colour, brighter while splashing.
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0, 0.1),
                            radius: 0.55,
                            colors: [
                              liquid.withValues(alpha: 0.45 + 0.3 * splash),
                              liquid.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Transform.scale(
                        scale: gulp,
                        alignment: Alignment.bottomCenter,
                        child: Image.asset(
                          MagicCauldron.image,
                          fit: BoxFit.contain,
                          cacheWidth: 700,
                          excludeFromSemantics: true,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _PotionFx(
                            liquid: liquid,
                            t: _bubble.value,
                            splash: splash,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Bubbles and splash drawn over the potion surface of `cauldron.png`
/// (the surface sits at about 44% height, between 30% and 70% width).
class _PotionFx extends CustomPainter {
  _PotionFx({required this.liquid, required this.t, required this.splash});

  final Color liquid;
  final double t;
  final double splash;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final surfaceY = h * 0.44;
    final halfW = w * 0.19;
    final light = Color.lerp(liquid, Colors.white, 0.5)!;

    // Bubbles rising from the potion and popping.
    for (var i = 0; i < 6; i++) {
      final p = (t * 1.6 + i / 6) % 1;
      final x = w / 2 + math.cos(i * 2.1) * halfW * 0.8;
      final y = surfaceY - p * h * 0.1;
      final r = w * (0.012 + 0.008 * (i % 3)) * (1 - p * 0.4);
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = light.withValues(alpha: 0.85 * (1 - p)),
      );
      canvas.drawCircle(
        Offset(x - r * 0.35, y - r * 0.35),
        r * 0.3,
        Paint()..color = Colors.white.withValues(alpha: 0.7 * (1 - p)),
      );
    }

    // Splash: droplets jump up from the surface and fall back.
    if (splash > 0) {
      final rise = math.sin(splash * math.pi);
      for (var i = 0; i < 9; i++) {
        final a = math.pi * (0.1 + 0.8 * i / 8);
        final x = w / 2 - math.cos(a) * halfW * (0.4 + 0.9 * splash);
        final y = surfaceY - rise * h * 0.22 * math.sin(a);
        canvas.drawCircle(
          Offset(x, y),
          w * 0.02 * (1 - splash * 0.5),
          Paint()..color = light.withValues(alpha: 1 - splash),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PotionFx old) =>
      old.t != t || old.splash != splash || old.liquid != liquid;
}
