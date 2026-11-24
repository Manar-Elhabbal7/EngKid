import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:engkids/app/theme.dart';

/// A small pumpkin with a letter, tapped to spell the word.
/// Fades out once [used]; glows gold when it's the [hint];
/// shakes each time [shakeToken] changes.
class LetterTile extends StatefulWidget {
  const LetterTile({
    super.key,
    required this.letter,
    required this.size,
    required this.used,
    required this.hint,
    required this.shakeToken,
    required this.onTap,
  });

  static const image = 'assets/images/pumpkin_blank.png';

  final String letter;
  final double size;
  final bool used;
  final bool hint;
  final int shakeToken;
  final VoidCallback onTap;

  @override
  State<LetterTile> createState() => _LetterTileState();
}

class _LetterTileState extends State<LetterTile> with TickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  var _pressed = false;

  @override
  void initState() {
    super.initState();
    if (widget.hint) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(LetterTile old) {
    super.didUpdateWidget(old);
    if (widget.shakeToken != old.shakeToken) _shake.forward(from: 0);
    if (widget.hint && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.hint && _pulse.isAnimating) {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final tile = AnimatedBuilder(
      animation: Listenable.merge([_shake, _pulse]),
      builder: (context, child) {
        final t = _shake.value;
        final dx = math.sin(t * math.pi * 6) * 8 * (1 - t);
        final glow = widget.hint ? 0.45 + 0.4 * _pulse.value : 0.0;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                if (glow > 0)
                  BoxShadow(
                    color: HalloweenColors.gold.withValues(alpha: glow),
                    blurRadius: 22,
                    spreadRadius: 4,
                  ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1,
        duration: const Duration(milliseconds: 120),
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                LetterTile.image,
                width: size,
                height: size,
                cacheWidth: 220,
                excludeFromSemantics: true,
              ),
              Align(
                alignment: const Alignment(0, 0.25),
                child: Text(
                  widget.letter,
                  style: TextStyle(
                    fontFamily: 'Baloo2',
                    fontWeight: FontWeight.w800,
                    fontSize: size * 0.42,
                    height: 1,
                    color: const Color(0xFFFFF3C0),
                    shadows: const [
                      Shadow(color: Color(0xFF8A3A00), blurRadius: 6),
                      Shadow(color: Color(0xFF8A3A00), offset: Offset(0, 2)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: widget.used ? 0.2 : 1,
      // Used tiles keep their space but are skipped by taps and screen readers.
      child: widget.used
          ? ExcludeSemantics(child: IgnorePointer(child: tile))
          : Semantics(
              button: true,
              label: 'Letter ${widget.letter}',
              excludeSemantics: true,
              child: GestureDetector(
                onTapDown: (_) => setState(() => _pressed = true),
                onTapCancel: () => setState(() => _pressed = false),
                onTapUp: (_) {
                  setState(() => _pressed = false);
                  HapticFeedback.mediumImpact();
                  widget.onTap();
                },
                child: tile,
              ),
            ),
    );
  }
}
