import 'package:flutter/material.dart';

/// Colours for the dashboard's paper-and-wood look.
abstract final class ParchmentColors {
  static const top = Color(0xFFF7E6BE);
  static const bottom = Color(0xFFE8CB93);
  static const rim = Color(0xFF8A5A2B);
  static const ink = Color(0xFF5E3714);
  static const pill = Color(0xFFFBF0D4);
  static const track = Color(0xFFD9BF8C);
}

/// Rounded parchment card with a wooden rim.
class ParchmentPanel extends StatelessWidget {
  const ParchmentPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [ParchmentColors.top, ParchmentColors.bottom],
        ),
        border: Border.all(color: ParchmentColors.rim, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99080016),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
