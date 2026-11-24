import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:engkids/app/theme.dart';

/// White speech bubble with a small tail pointing down-left at Boo.
class SpeechBubble extends StatelessWidget {
  const SpeechBubble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 260),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              text,
              key: ValueKey(text),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: HalloweenColors.deepPurple,
                fontSize: 19,
                height: 1.15,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 34),
          child: CustomPaint(size: const Size(22, 14), painter: _Tail()),
        ),
      ],
    );
  }
}

class _Tail extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.15, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Boo in his bow tie, gently floating up and down.
class FloatingBoo extends StatefulWidget {
  const FloatingBoo({super.key, required this.size});

  static const image = 'assets/images/boo_bowtie.png';

  final double size;

  @override
  State<FloatingBoo> createState() => _FloatingBooState();
}

class _FloatingBooState extends State<FloatingBoo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, 6 * math.sin(_float.value * math.pi * 2)),
        child: child,
      ),
      child: Image.asset(
        FloatingBoo.image,
        width: widget.size,
        height: widget.size,
        cacheWidth: 700,
        fit: BoxFit.contain,
        semanticLabel: 'Boo the ghost',
      ),
    );
  }
}
