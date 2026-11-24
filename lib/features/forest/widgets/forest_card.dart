import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:engkids/app/theme.dart';
import 'package:engkids/features/forest/models/forest.dart';

/// A card found in the forest. Front: just the picture. Tapping flips it to
/// show the written word while it's said; it stays showing the word after.
class ForestCard extends StatefulWidget {
  const ForestCard({
    super.key,
    required this.word,
    required this.size,
    required this.revealed,
    required this.speaking,
    required this.onTap,
  });

  final ForestWord word;
  final double size;

  /// Shows the word side. True while speaking and once the word is heard.
  final bool revealed;
  final bool speaking;
  final VoidCallback onTap;

  @override
  State<ForestCard> createState() => _ForestCardState();
}

class _ForestCardState extends State<ForestCard> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final w = widget.size * 0.8;
    final h = widget.size;
    final scale = _pressed ? 0.94 : (widget.speaking ? 1.05 : 1.0);
    return Semantics(
      button: true,
      label: 'Picture of ${widget.word.word}. Tap to hear it.',
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: widget.revealed ? 1 : 0),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeInOut,
            builder: (context, t, _) {
              final back = t >= 0.5;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateY(math.pi * t),
                child: Transform(
                  // Un-mirror the back side once the card has turned over.
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(back ? math.pi : 0),
                  child: SizedBox(
                    width: w,
                    height: h,
                    child: back
                        ? _Back(word: widget.word, glow: widget.speaking)
                        : _Front(emoji: widget.word.emoji),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

BoxDecoration _cardFrame(List<Color> colors, {required double glow}) =>
    BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ),
      border: Border.all(color: const Color(0xFFE8C27A), width: 4),
      boxShadow: [
        BoxShadow(
          color: HalloweenColors.orange.withValues(alpha: glow),
          blurRadius: 26,
          spreadRadius: 2,
        ),
        const BoxShadow(
          color: Color(0x99000000),
          blurRadius: 12,
          offset: Offset(0, 6),
        ),
      ],
    );

class _Front extends StatelessWidget {
  const _Front({required this.emoji});

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardFrame(const [
        Color(0xFF4A2A7A),
        Color(0xFF2A1450),
      ], glow: 0.35),
      child: LayoutBuilder(
        builder: (context, box) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: box.maxWidth * 0.5)),
            SizedBox(height: box.maxHeight * 0.04),
            Icon(
              Icons.touch_app_rounded,
              color: HalloweenColors.gold.withValues(alpha: 0.85),
              size: box.maxWidth * 0.14,
            ),
          ],
        ),
      ),
    );
  }
}

class _Back extends StatelessWidget {
  const _Back({required this.word, required this.glow});

  final ForestWord word;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardFrame(const [
        Color(0xFFFBF0D4),
        Color(0xFFE8CB93),
      ], glow: glow ? 0.8 : 0.4),
      padding: const EdgeInsets.all(10),
      child: LayoutBuilder(
        builder: (context, box) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(word.emoji, style: TextStyle(fontSize: box.maxWidth * 0.34)),
            SizedBox(height: box.maxHeight * 0.03),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                word.word,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: 'Baloo2',
                  fontWeight: FontWeight.w800,
                  fontSize: box.maxWidth * 0.24,
                  height: 1,
                  color: HalloweenColors.deepPurple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
