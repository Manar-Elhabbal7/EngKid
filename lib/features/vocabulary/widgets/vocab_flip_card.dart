import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../models/vocab_data.dart';

/// A 3-D flip card for vocabulary.
///
/// Front face: large emoji + "Trick or Treat?" prompt.
/// Back face : word text + category label.
///
/// Flip is triggered by [isFlipped]. Parent controls state.
class VocabFlipCard extends StatefulWidget {
  const VocabFlipCard({
    super.key,
    required this.word,
    required this.categoryColor,
    required this.isFlipped,
    required this.isLearned,
    required this.onTap,
  });

  final VocabWord word;
  final Color categoryColor;
  final bool isFlipped;
  final bool isLearned;
  final VoidCallback onTap;

  @override
  State<VocabFlipCard> createState() => _VocabFlipCardState();
}

class _VocabFlipCardState extends State<VocabFlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _anim = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.isFlipped) _ctrl.value = 1;
  }

  @override
  void didUpdateWidget(VocabFlipCard old) {
    super.didUpdateWidget(old);
    if (widget.isFlipped != old.isFlipped) {
      widget.isFlipped ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final cardW = size.shortestSide * 0.70;
    final cardH = cardW * 1.15;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, child) {
          final angle = _anim.value;
          final showFront = angle < math.pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: SizedBox(
              width: cardW,
              height: cardH,
              child: showFront
                  ? _FrontFace(
                      word: widget.word,
                      color: widget.categoryColor,
                      isLearned: widget.isLearned,
                    )
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: _BackFace(
                        word: widget.word,
                        color: widget.categoryColor,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Front face — emoji + "Trick or Treat?" prompt
// ─────────────────────────────────────────────────────────────────────────────

class _FrontFace extends StatelessWidget {
  const _FrontFace({
    required this.word,
    required this.color,
    required this.isLearned,
  });
  final VocabWord word;
  final Color color;
  final bool isLearned;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.85),
            color.withValues(alpha: 0.55),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(word.emoji, style: const TextStyle(fontSize: 72)),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎃', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(
                        'Trick or Treat?',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: HalloweenColors.ghostWhite,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tap to flip!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          if (isLearned)
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

// ─────────────────────────────────────────────────────────────────────────────
// Back face — word + category + TTS hint
// ─────────────────────────────────────────────────────────────────────────────

class _BackFace extends StatelessWidget {
  const _BackFace({required this.word, required this.color});
  final VocabWord word;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HalloweenColors.deepPurple,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: HalloweenColors.pumpkinYellow, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: HalloweenColors.pumpkinYellow.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              word.word,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: HalloweenColors.pumpkinYellow,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color, width: 1.5),
              ),
              child: Text(
                word.category,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.volume_up_rounded,
                    color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Tap to hear the word!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
