import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:engkids/features/alphabet/models/alphabet.dart';

/// The big pumpkin with the current letter glowing on it. One blank
/// pumpkin image is reused for all 26 letters.
class LetterPumpkin extends StatefulWidget {
  const LetterPumpkin({
    super.key,
    required this.letter,
    required this.size,
    required this.speaking,
    required this.onTap,
  });

  static const image = 'assets/images/pumpkin_blank.png';

  final AlphabetLetter letter;
  final double size;

  /// Glows brighter and grows a little while the letter is being said.
  final bool speaking;
  final VoidCallback onTap;

  @override
  State<LetterPumpkin> createState() => _LetterPumpkinState();
}

class _LetterPumpkinState extends State<LetterPumpkin> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final scale = _pressed ? 0.93 : (widget.speaking ? 1.06 : 1.0);
    return Semantics(
      button: true,
      label: 'Letter ${widget.letter.letter}. Tap to hear it.',
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
          child: SizedBox.square(
            dimension: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  LetterPumpkin.image,
                  width: size,
                  height: size,
                  cacheWidth: 900,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
                // The pumpkin's body sits a bit below the image centre.
                Align(
                  alignment: const Alignment(0, 0.22),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: _GlowLetter(
                      key: ValueKey(widget.letter.letter),
                      letter: widget.letter.letter,
                      fontSize: size * 0.44,
                      bright: widget.speaking,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Candle-lit letter: warm yellow fill with an orange glow, like light
/// coming through a carved pumpkin.
class _GlowLetter extends StatelessWidget {
  const _GlowLetter({
    super.key,
    required this.letter,
    required this.fontSize,
    required this.bright,
  });

  final String letter;
  final double fontSize;
  final bool bright;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: 'Baloo2',
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      height: 1,
    );
    return Stack(
      children: [
        // Glow behind the letter.
        Text(
          letter,
          style: style.copyWith(
            color: const Color(0xFFFFE27A),
            shadows: [
              Shadow(
                color: const Color(0xFFFF8A00),
                blurRadius: bright ? 34 : 22,
              ),
              Shadow(
                color: const Color(0xCCFFC440),
                blurRadius: bright ? 14 : 8,
              ),
            ],
          ),
        ),
        // Lit fill.
        ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF6C8), Color(0xFFFFC94A), Color(0xFFFF9A1F)],
          ).createShader(rect),
          child: Text(letter, style: style.copyWith(color: Colors.white)),
        ),
      ],
    );
  }
}
