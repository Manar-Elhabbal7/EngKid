import 'package:flutter/material.dart';
import 'package:engkids/app/theme.dart';

/// The word being spelled: one parchment slot per letter. Filled letters
/// pop in; the next empty slot glows gold. All slots turn green when done.
class LetterSlots extends StatelessWidget {
  const LetterSlots({
    super.key,
    required this.word,
    required this.filled,
    required this.size,
  });

  /// Uppercase word, e.g. "OWL".
  final String word;

  /// How many letters are already in place.
  final int filled;
  final double size;

  @override
  Widget build(BuildContext context) {
    final done = filled >= word.length;
    final shown = [
      for (var i = 0; i < word.length; i++) i < filled ? word[i] : '_',
    ].join(' ');
    return Semantics(
      label: 'Spelled so far: $shown',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < word.length; i++)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size * 0.08),
              child: _Slot(
                letter: i < filled ? word[i] : null,
                current: i == filled,
                done: done,
                size: size,
              ),
            ),
        ],
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({
    required this.letter,
    required this.current,
    required this.done,
    required this.size,
  });

  final String? letter;
  final bool current;
  final bool done;
  final double size;

  @override
  Widget build(BuildContext context) {
    final rim = done
        ? HalloweenColors.playGreen
        : current
        ? HalloweenColors.gold
        : const Color(0xFFB98A4E);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: size,
      height: size * 1.15,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFBF0D4), Color(0xFFE8CB93)],
        ),
        border: Border.all(color: rim, width: current || done ? 4 : 3),
        boxShadow: [
          BoxShadow(
            color: current
                ? HalloweenColors.gold.withValues(alpha: 0.6)
                : done
                ? HalloweenColors.playGreen.withValues(alpha: 0.5)
                : const Color(0x66000000),
            blurRadius: current || done ? 16 : 8,
          ),
        ],
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
            child: child,
          ),
          child: Text(
            letter ?? '',
            key: ValueKey(letter),
            style: TextStyle(
              fontFamily: 'Baloo2',
              fontWeight: FontWeight.w800,
              fontSize: size * 0.62,
              height: 1,
              color: HalloweenColors.deepPurple,
            ),
          ),
        ),
      ),
    );
  }
}
