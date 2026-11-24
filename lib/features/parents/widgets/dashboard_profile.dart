import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:engkids/features/parents/widgets/parchment_panel.dart';
import 'package:engkids/features/profiles/models/profile.dart';
import 'package:engkids/features/profiles/widgets/avatar_art.dart';

/// Round framed avatar with the player's name and an edit pencil.
/// The pencil is hidden when [onEdit] is null (e.g. for Boo).
class DashboardProfile extends StatelessWidget {
  const DashboardProfile({super.key, required this.profile, this.onEdit});

  final Profile profile;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ParchmentColors.rim, width: 4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ClipOval(child: AvatarArt(avatar: profile.avatar)),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                profile.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(color: ParchmentColors.ink, fontSize: 22),
              ),
            ),
            if (onEdit != null) ...[
              const SizedBox(width: 2),
              IconButton(
                tooltip: 'Rename ${profile.name}',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onEdit!();
                },
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: ParchmentColors.pill,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ParchmentColors.rim, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 18,
                    color: ParchmentColors.ink,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
