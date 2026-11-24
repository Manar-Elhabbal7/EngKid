import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:engkids/app/theme.dart';
import 'package:engkids/features/forest/models/forest.dart';

/// The picture to spell, in a purple card like the forest cards, with a
/// speaker badge. Tapping it says the word.
class SpellPicture extends StatelessWidget {
  const SpellPicture({
    super.key,
    required this.word,
    required this.size,
    required this.glow,
    required this.onTap,
  });

  final ForestWord word;
  final double size;

  /// Bright green glow once the word is spelled.
  final bool glow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Picture of ${word.word}. Tap to hear it.',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4A2A7A), Color(0xFF2A1450)],
            ),
            border: Border.all(
              color: glow ? HalloweenColors.playGreen : const Color(0xFFE8C27A),
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: glow
                    ? HalloweenColors.playGreen.withValues(alpha: 0.6)
                    : HalloweenColors.orange.withValues(alpha: 0.35),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  word.emoji,
                  style: TextStyle(fontSize: size * 0.55),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: HalloweenColors.orange,
                    border: Border.all(
                      color: const Color(0xFFFFE08A),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.volume_up_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
