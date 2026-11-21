import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme.dart';
import '../models/letter_data.dart';

/// The main card shown for each letter — styled as a glowing carved pumpkin.
///
/// [isVisited] dims the card slightly when already seen.
/// [onTap] fires when the child taps the card — parent handles TTS + star award.
class PumpkinLetterCard extends StatelessWidget {
  const PumpkinLetterCard({
    super.key,
    required this.entry,
    required this.onTap,
    this.isVisited = false,
  });

  final LetterEntry entry;
  final VoidCallback onTap;
  final bool isVisited;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final cardSize = size.shortestSide * 0.72;

    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: SizedBox(
          width: cardSize,
          height: cardSize,
          child: _CardBody(entry: entry, isVisited: isVisited),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .scaleXY(
              begin: 0.88,
              end: 1.0,
              duration: 400.ms,
              curve: Curves.easeOut,
            ),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.entry, required this.isVisited});
  final LetterEntry entry;
  final bool isVisited;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF8C00),
            HalloweenColors.pumpkinOrange,
            const Color(0xFFCC5500),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: HalloweenColors.pumpkinYellow,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: HalloweenColors.pumpkinOrange.withValues(alpha: 0.6),
            blurRadius: 32,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Pumpkin texture lines
          Positioned.fill(
            child: CustomPaint(painter: _PumpkinLinePainter()),
          ),

          // Card content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // ── Big letter ───────────────────────────────
                Text(
                  entry.letter,
                  style: TextStyle(
                    fontSize: 96,
                    fontWeight: FontWeight.w900,
                    color: HalloweenColors.ghostWhite,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                ),

                // ── Emoji ─────────────────────────────────────
                Text(
                  entry.emoji,
                  style: const TextStyle(fontSize: 56),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(
                      begin: 1.0,
                      end: 1.12,
                      duration: 1200.ms,
                      curve: Curves.easeInOut,
                    ),

                // ── Example word ──────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    entry.word,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: HalloweenColors.ghostWhite,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),

                // ── Tap hint ──────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.volume_up_rounded,
                        color: Colors.white70, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Tap to hear!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Visited check badge
          if (isVisited)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: HalloweenColors.starGold,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: HalloweenColors.starGold.withValues(alpha: 0.6),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
        ],
      ),
    );
  }
}

/// Draws subtle vertical curved lines to suggest a carved pumpkin surface.
class _PumpkinLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var i = 1; i <= 4; i++) {
      final x = size.width * i / 5;
      final path = Path()
        ..moveTo(x, size.height * 0.1)
        ..cubicTo(
          x - 10, size.height * 0.4,
          x + 10, size.height * 0.6,
          x, size.height * 0.9,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_PumpkinLinePainter old) => false;
}
