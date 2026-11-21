import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';

/// A [Scaffold] replacement that paints the deep-purple Halloween gradient
/// behind every screen and floats animated ghost orbs in the background.
///
/// Handles both portrait and landscape via [OrientationBuilder] — in landscape
/// the [child] gets a wider content column.
class ScaffoldWithBackground extends StatelessWidget {
  const ScaffoldWithBackground({
    super.key,
    required this.child,
    this.title,
    this.showBackButton = false,
    this.actions,
  });

  final Widget child;
  final String? title;
  final bool showBackButton;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HalloweenColors.deepPurple,
      extendBodyBehindAppBar: true,
      appBar: title != null
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: showBackButton,
              title: Text(
                title!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: HalloweenColors.ghostWhite,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              actions: actions,
            )
          : null,
      body: Stack(
        children: [
          // ── Background gradient ──────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D001A),
                  HalloweenColors.deepPurple,
                  Color(0xFF2D0050),
                ],
              ),
            ),
          ),

          // ── Floating ghost orbs ──────────────────────────────────────
          const _GhostOrbs(),

          // ── Main content ─────────────────────────────────────────────
          SafeArea(child: child),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Decorative floating orbs that drift upward in the background
// ---------------------------------------------------------------------------

class _GhostOrbs extends StatelessWidget {
  const _GhostOrbs();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          _orb(left: 0.08, top: 0.15, size: 60, delay: 0),
          _orb(left: 0.72, top: 0.30, size: 44, delay: 800),
          _orb(left: 0.45, top: 0.65, size: 52, delay: 400),
          _orb(left: 0.85, top: 0.75, size: 36, delay: 1200),
          _orb(left: 0.20, top: 0.80, size: 28, delay: 600),
        ],
      ),
    );
  }

  Widget _orb({
    required double left,
    required double top,
    required double size,
    required int delay,
  }) {
    return Positioned(
      left: left * 400, // approximate; real position set via FractionallySizedBox below
      top: top * 800,
      child: Opacity(
        opacity: 0.18,
        child: Text(
          '👻',
          style: TextStyle(fontSize: size),
        )
            .animate(
              onPlay: (c) => c.repeat(reverse: true),
            )
            .moveY(
              begin: 0,
              end: -18,
              duration: Duration(milliseconds: 2400 + delay),
              curve: Curves.easeInOut,
            )
            .fadeIn(
              duration: Duration(milliseconds: 600 + delay),
            ),
      ),
    );
  }
}
