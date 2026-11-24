import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engkids/app/theme.dart';
import 'package:engkids/features/profiles/models/profile.dart';
import 'package:engkids/features/profiles/providers/profiles_provider.dart';
import 'package:engkids/features/profiles/widgets/avatar_art.dart';
import 'package:engkids/shared/audio/audio_service.dart';

/// Bottom sheet for a new player: type a name, pick a character.
/// Pops with `(name, avatarId)` on save, or null when dismissed.
class AddProfileSheet extends ConsumerStatefulWidget {
  const AddProfileSheet({super.key});

  static Future<(String, String)?> show(BuildContext context) {
    return showModalBottomSheet<(String, String)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: HalloweenColors.castlePurple,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const AddProfileSheet(),
    );
  }

  @override
  ConsumerState<AddProfileSheet> createState() => _AddProfileSheetState();
}

class _AddProfileSheetState extends ConsumerState<AddProfileSheet> {
  final _name = TextEditingController();
  var _avatarId = Avatars.costumes.first.id;

  bool get _canSave => _name.text.trim().isNotEmpty;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _pick(String id) {
    HapticFeedback.selectionClick();
    ref.read(audioServiceProvider).playSfx('audio/sparkle.mp3');
    setState(() => _avatarId = id);
  }

  void _save() {
    if (!_canSave) return;
    HapticFeedback.mediumImpact();
    ref.read(audioServiceProvider).playSfx('audio/chime.mp3');
    Navigator.of(context).pop((_name.text, _avatarId));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'New player',
              textAlign: TextAlign.center,
              style: text.headlineMedium?.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              autofocus: true,
              maxLength: ProfilesNotifier.maxNameLength,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _save(),
              style: text.bodyLarge?.copyWith(
                color: HalloweenColors.deepPurple,
              ),
              decoration: InputDecoration(
                hintText: "What's your name?",
                filled: true,
                fillColor: HalloweenColors.cream,
                counterStyle: const TextStyle(color: HalloweenColors.cream),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('Pick your costume', style: text.titleLarge),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                for (final a in Avatars.costumes)
                  _AvatarChoice(
                    avatar: a,
                    selected: a.id == _avatarId,
                    onTap: () => _pick(a.id),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _canSave ? _save : null,
              icon: const Icon(Icons.check_rounded, size: 28),
              label: const Text('Save'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: HalloweenColors.orange,
                foregroundColor: Colors.white,
                textStyle: text.titleLarge?.copyWith(fontSize: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarChoice extends StatelessWidget {
  const _AvatarChoice({
    required this.avatar,
    required this.selected,
    required this.onTap,
  });

  final AvatarOption avatar;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: avatar.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? HalloweenColors.gold : Colors.transparent,
              width: 3,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: AvatarArt(avatar: avatar),
          ),
        ),
      ),
    );
  }
}
