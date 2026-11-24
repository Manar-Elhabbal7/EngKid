import 'package:flutter/material.dart';

/// The moonlit graveyard behind every lesson. Uses the tall picture in
/// portrait and the wide one in landscape, darkened at the top so the
/// header stays readable.
class LessonBackground extends StatelessWidget {
  const LessonBackground({super.key, required this.wide});

  static const portrait = 'assets/images/alphabet_bg.jpg';
  static const landscape = 'assets/images/background_alpha.png';

  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          wide ? landscape : portrait,
          fit: BoxFit.cover,
          cacheWidth: 1600,
          excludeFromSemantics: true,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x99100318), Colors.transparent],
              stops: [0, 0.3],
            ),
          ),
        ),
      ],
    );
  }
}
