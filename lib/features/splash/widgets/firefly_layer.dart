import 'dart:math' as math;

import 'package:flutter/material.dart';

class FireflyLayer extends StatelessWidget {
  const FireflyLayer({super.key, required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: FireflyPainter(t: t),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class FireflyPainter extends CustomPainter {
  FireflyPainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 20; i++) {
      final seed = i * 13.37;
      final baseX = (math.sin(seed) * 0.5 + 0.5) * size.width;
      final baseY = (math.cos(seed * 1.17) * 0.5 + 0.5) * size.height * 0.78;
      final phase = t * math.pi * 2 + seed;
      final x = baseX + 10 * math.sin(phase * 0.65);
      final y = baseY + 8 * math.cos(phase * 0.8);
      final glow = 0.25 + 0.75 * (0.5 + 0.5 * math.sin(phase));
      final radius = 1.6 + (i % 4) * 0.55;

      final paint = Paint()
        ..color = Color.fromRGBO(255, 214, 90, (0.55 * glow).clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(x, y), radius * 3.2, paint);
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = Color.fromRGBO(255, 248, 210, glow.clamp(0.0, 1.0)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant FireflyPainter oldDelegate) =>
      oldDelegate.t != t;
}
