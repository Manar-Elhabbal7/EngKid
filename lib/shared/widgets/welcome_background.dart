import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// The moonlit forest with Boo behind the menu screens (home, profiles,
/// game list, parents).
///
/// The picture is tall (720×1280). On tall screens it fills the screen.
/// On wide screens (web, landscape) filling would zoom it far in, so a
/// blurred copy fills the screen and the whole picture sits centred on top.
class WelcomeBackground extends StatelessWidget {
  const WelcomeBackground({
    super.key,
    this.label,
    this.alignment = const Alignment(0, -0.2),
  });

  static const image = 'assets/images/welcome_scene.jpg';

  /// Screen-reader description; null keeps the picture silent (decoration).
  final String? label;

  /// Which part stays in view when a tall screen crops the sides.
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        if (box.maxWidth <= box.maxHeight) {
          return Image.asset(
            image,
            fit: BoxFit.cover,
            alignment: alignment,
            filterQuality: FilterQuality.high,
            semanticLabel: label,
            excludeFromSemantics: label == null,
          );
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            // Soft, dark fill for the sides.
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Color(0x99120418),
                  BlendMode.srcATop,
                ),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  cacheWidth: 400,
                  excludeFromSemantics: true,
                ),
              ),
            ),
            Image.asset(
              image,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              semanticLabel: label,
              excludeFromSemantics: label == null,
            ),
          ],
        );
      },
    );
  }
}
