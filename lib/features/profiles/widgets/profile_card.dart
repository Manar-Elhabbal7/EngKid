import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:engkids/app/theme.dart';
import 'package:engkids/features/profiles/models/profile.dart';
import 'package:engkids/features/profiles/widgets/avatar_art.dart';

/// A tall framed portrait with the player's name underneath,
/// styled like the cards on the "Who is playing today?" mockup.
///
/// When [onDelete] is set, a trash badge sits on the card's top-right corner.
class ProfileCard extends StatefulWidget {
  const ProfileCard({
    super.key,
    required this.profile,
    required this.width,
    required this.onTap,
    this.onDelete,
  });

  final Profile profile;
  final double width;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final avatar = widget.profile.avatar;
    return SizedBox(
      width: widget.width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Semantics(
            button: true,
            label: 'Play as ${widget.profile.name}',
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
                scale: _pressed ? 0.94 : 1,
                duration: const Duration(milliseconds: 90),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: widget.width,
                      height: widget.width * 1.32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFFFFE6B8),
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: avatar.bottom.withValues(alpha: 0.55),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: AvatarArt(avatar: avatar),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.profile.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: HalloweenColors.cream,
                        fontSize: 20,
                        shadows: const [
                          Shadow(color: Color(0xCC1A0030), blurRadius: 6),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (widget.onDelete != null)
            Positioned(
              top: -14,
              right: -14,
              child: _DeleteBadge(
                name: widget.profile.name,
                onTap: widget.onDelete!,
              ),
            ),
        ],
      ),
    );
  }
}

/// Round trash button; 48×48 tap area around a 38px badge.
class _DeleteBadge extends StatelessWidget {
  const _DeleteBadge({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Delete $name',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: HalloweenColors.castlePurple,
                border: Border.all(color: const Color(0xFFFFE6B8), width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x99000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.delete_rounded,
                color: HalloweenColors.cream,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
