import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:engkids/app/theme.dart';
import 'package:engkids/features/forest/models/forest.dart';
import 'package:engkids/features/matching/widgets/match_tile.dart';

/// Pictures on the left, the same words shuffled on the right, on a dark
/// gold-rimmed panel. Each matched pair is joined by a glowing rope.
class MatchBoard extends StatelessWidget {
  const MatchBoard({
    super.key,
    required this.pictures,
    required this.words,
    required this.matched,
    required this.selectedPicture,
    required this.selectedWord,
    required this.shakes,
    required this.onPictureTap,
    required this.onWordTap,
  });

  /// Left column, in round order.
  final List<ForestWord> pictures;

  /// Right column, shuffled.
  final List<ForestWord> words;
  final Set<String> matched;
  final String? selectedPicture;
  final String? selectedWord;

  /// Shake counters keyed by `p:<key>` / `w:<key>`.
  final Map<String, int> shakes;
  final void Function(ForestWord) onPictureTap;
  final void Function(ForestWord) onWordTap;

  MatchTileState _state(String key, String? selectedKey) =>
      matched.contains(key)
      ? MatchTileState.matched
      : key == selectedKey
      ? MatchTileState.selected
      : MatchTileState.idle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xB31A0A30),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0x99E8C27A), width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), blurRadius: 20, spreadRadius: 2),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final n = pictures.length;
          final w = box.maxWidth;
          final gap = (w * 0.14).clamp(30.0, 72.0);
          final colW = (w - gap) / 2;
          const rowGap = 12.0;
          final tileH = math.max(
            48.0,
            math.min((box.maxHeight - rowGap * (n - 1)) / n, colW * 0.62),
          );
          final used = tileH * n + rowGap * (n - 1);
          final top = math.max(0.0, (box.maxHeight - used) / 2);
          double rowTop(int i) => top + i * (tileH + rowGap);
          double rowMid(int i) => rowTop(i) + tileH / 2;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Ropes first, so their ends tuck under the cards.
              for (final p in pictures)
                if (matched.contains(p.key))
                  Positioned.fill(
                    child: _Rope(
                      key: ValueKey('rope-${p.key}'),
                      from: Offset(colW - 4, rowMid(pictures.indexOf(p))),
                      to: Offset(colW + gap + 4, rowMid(words.indexOf(p))),
                    ),
                  ),
              for (var i = 0; i < n; i++) ...[
                Positioned(
                  left: 0,
                  top: rowTop(i),
                  width: colW,
                  height: tileH,
                  child: MatchTile(
                    label: pictures[i].emoji,
                    semanticsLabel: 'Picture: ${pictures[i].word}',
                    isPicture: true,
                    state: _state(pictures[i].key, selectedPicture),
                    shakeToken: shakes['p:${pictures[i].key}'] ?? 0,
                    onTap: () => onPictureTap(pictures[i]),
                  ),
                ),
                Positioned(
                  left: colW + gap,
                  top: rowTop(i),
                  width: colW,
                  height: tileH,
                  child: MatchTile(
                    label: words[i].word,
                    semanticsLabel: 'Word: ${words[i].word}',
                    isPicture: false,
                    state: _state(words[i].key, selectedWord),
                    shakeToken: shakes['w:${words[i].key}'] ?? 0,
                    onTap: () => onWordTap(words[i]),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// A glowing gold rope that draws itself from [from] to [to] once.
class _Rope extends StatelessWidget {
  const _Rope({super.key, required this.from, required this.to});

  final Offset from;
  final Offset to;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) => CustomPaint(
          painter: _RopePainter(from: from, to: to, progress: t),
        ),
      ),
    );
  }
}

class _RopePainter extends CustomPainter {
  _RopePainter({required this.from, required this.to, required this.progress});

  final Offset from;
  final Offset to;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final dx = (to.dx - from.dx) * 0.55;
    final full = Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(from.dx + dx, from.dy, to.dx - dx, to.dy, to.dx, to.dy);
    final metric = full.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * progress);

    canvas.drawPath(
      drawn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 12
        ..color = HalloweenColors.gold.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawPath(
      drawn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 4
        ..color = const Color(0xFFFFE27A),
    );
    // A spark rides the tip while the rope is drawing.
    final tip = metric.getTangentForOffset(metric.length * progress)?.position;
    if (tip != null && progress < 1) {
      canvas.drawCircle(
        tip,
        7,
        Paint()
          ..color = Colors.white
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RopePainter old) =>
      old.progress != progress || old.from != from || old.to != to;
}
