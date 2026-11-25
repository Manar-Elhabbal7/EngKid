import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:engkids/app/theme.dart';
import 'package:engkids/features/forest/models/forest.dart';

/// A floating bubble holding one ingredient. Bobs gently; shakes when
/// [shakeToken] changes; once [dropped], it shrinks and falls into the pot.
class IngredientOrb extends StatefulWidget {
  const IngredientOrb({
    super.key,
    required this.word,
    required this.size,
    required this.index,
    required this.dropped,
    required this.shakeToken,
    required this.onTap,
  });

  final ForestWord word;
  final double size;

  /// Offsets the bobbing so the three bubbles don't move together.
  final int index;
  final bool dropped;
  final int shakeToken;
  final VoidCallback onTap;

  @override
  State<IngredientOrb> createState() => _IngredientOrbState();
}

class _IngredientOrbState extends State<IngredientOrb>
    with TickerProviderStateMixin {
  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 2200 + widget.index * 350),
  )..repeat();
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void didUpdateWidget(IngredientOrb old) {
    super.didUpdateWidget(old);
    if (widget.shakeToken != old.shakeToken) _shake.forward(from: 0);
  }

  @override
  void dispose() {
    _bob.dispose();
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final orb = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.4),
          colors: [Color(0xFF6A3FB0), Color(0xFF2A1450)],
        ),
        border: Border.all(color: const Color(0xFFE8C27A), width: 3),
        boxShadow: [
          BoxShadow(
            color: HalloweenColors.gold.withValues(alpha: 0.35),
            blurRadius: 16,
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              widget.word.emoji,
              style: TextStyle(fontSize: size * 0.5),
            ),
          ),
          // Bubble shine.
          Positioned(
            left: size * 0.2,
            top: size * 0.14,
            child: Container(
              width: size * 0.2,
              height: size * 0.12,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(size),
              ),
            ),
          ),
        ],
      ),
    );

    return AnimatedSlide(
      offset: widget.dropped ? const Offset(0, 1.6) : Offset.zero,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeIn,
      child: AnimatedScale(
        scale: widget.dropped ? 0 : 1,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeIn,
        child: AnimatedBuilder(
          animation: Listenable.merge([_bob, _shake]),
          builder: (context, child) {
            final bob = math.sin(_bob.value * math.pi * 2) * 6;
            final s = _shake.value;
            final dx = math.sin(s * math.pi * 6) * 9 * (1 - s);
            return Transform.translate(offset: Offset(dx, bob), child: child);
          },
          child: widget.dropped
              ? ExcludeSemantics(child: IgnorePointer(child: orb))
              : Semantics(
                  button: true,
                  label: 'Ingredient: ${widget.word.word}',
                  excludeSemantics: true,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      widget.onTap();
                    },
                    child: orb,
                  ),
                ),
        ),
      ),
    );
  }
}
