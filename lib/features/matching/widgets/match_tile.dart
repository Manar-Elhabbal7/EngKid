import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:engkids/app/theme.dart';

enum MatchTileState { idle, selected, matched }

/// One card on the matching board: a picture (purple, like the forest
/// cards) or a word (parchment). Shakes each time [shakeToken] changes.
class MatchTile extends StatefulWidget {
  const MatchTile({
    super.key,
    required this.label,
    required this.semanticsLabel,
    required this.isPicture,
    required this.state,
    required this.shakeToken,
    required this.onTap,
  });

  /// An emoji for pictures, the written word for words.
  final String label;
  final String semanticsLabel;
  final bool isPicture;
  final MatchTileState state;
  final int shakeToken;
  final VoidCallback onTap;

  @override
  State<MatchTile> createState() => _MatchTileState();
}

class _MatchTileState extends State<MatchTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  var _pressed = false;

  @override
  void didUpdateWidget(MatchTile old) {
    super.didUpdateWidget(old);
    if (widget.shakeToken != old.shakeToken) _shake.forward(from: 0);
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final matched = state == MatchTileState.matched;
    final selected = state == MatchTileState.selected;
    final scale = _pressed ? 0.94 : (selected ? 1.06 : 1.0);

    final rim = matched
        ? HalloweenColors.playGreen
        : selected
        ? HalloweenColors.gold
        : const Color(0xFFE8C27A);
    final glow = matched
        ? HalloweenColors.playGreen.withValues(alpha: 0.55)
        : selected
        ? HalloweenColors.gold.withValues(alpha: 0.7)
        : const Color(0x55000000);

    return Semantics(
      button: true,
      selected: selected,
      checked: matched,
      label: widget.semanticsLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: matched ? null : (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        child: AnimatedBuilder(
          animation: _shake,
          builder: (context, child) {
            final t = _shake.value;
            final dx = math.sin(t * math.pi * 6) * 9 * (1 - t);
            return Transform.translate(offset: Offset(dx, 0), child: child);
          },
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: widget.isPicture
                      ? const [Color(0xFF4A2A7A), Color(0xFF2A1450)]
                      : const [Color(0xFFFBF0D4), Color(0xFFE8CB93)],
                ),
                border: Border.all(color: rim, width: selected ? 4 : 3),
                boxShadow: [
                  BoxShadow(color: glow, blurRadius: selected ? 22 : 12),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: LayoutBuilder(
                      builder: (context, box) => Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.label,
                            maxLines: 1,
                            style: widget.isPicture
                                ? TextStyle(fontSize: box.maxHeight * 0.62)
                                : TextStyle(
                                    fontFamily: 'Baloo2',
                                    fontWeight: FontWeight.w800,
                                    fontSize: box.maxHeight * 0.4,
                                    height: 1,
                                    color: HalloweenColors.deepPurple,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (matched)
                    const Positioned(top: 6, right: 6, child: _CheckBadge()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckBadge extends StatelessWidget {
  const _CheckBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: HalloweenColors.playGreen,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
    );
  }
}
