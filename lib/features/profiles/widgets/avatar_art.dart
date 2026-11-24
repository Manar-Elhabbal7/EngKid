import 'package:flutter/material.dart';
import 'package:engkids/features/profiles/models/profile.dart';

/// The picture inside a profile frame: the avatar's image if it has one,
/// otherwise its emoji on the avatar's gradient.
class AvatarArt extends StatelessWidget {
  const AvatarArt({super.key, required this.avatar});

  final AvatarOption avatar;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [avatar.top, avatar.bottom],
        ),
      ),
      child: avatar.asset == null
          ? _Emoji(avatar.emoji)
          : Image.asset(
              avatar.asset!,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              excludeFromSemantics: true,
              // Missing file -> fall back to the emoji.
              errorBuilder: (context, error, stack) => _Emoji(avatar.emoji),
            ),
    );
  }
}

class _Emoji extends StatelessWidget {
  const _Emoji(this.emoji);

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => Center(
        child: Text(emoji, style: TextStyle(fontSize: c.maxWidth * 0.58)),
      ),
    );
  }
}
