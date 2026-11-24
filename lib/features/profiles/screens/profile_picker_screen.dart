import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:engkids/app/theme.dart';
import 'package:engkids/features/home/widgets/menu_pill_button.dart';
import 'package:engkids/features/home/widgets/mute_button.dart';
import 'package:engkids/features/home/widgets/wooden_sign.dart';
import 'package:engkids/features/profiles/models/profile.dart';
import 'package:engkids/features/profiles/providers/profiles_provider.dart';
import 'package:engkids/features/profiles/widgets/add_profile_sheet.dart';
import 'package:engkids/features/profiles/widgets/back_home_button.dart';
import 'package:engkids/features/profiles/widgets/profile_card.dart';
import 'package:engkids/features/splash/widgets/firefly_layer.dart';
import 'package:engkids/shared/audio/audio_service.dart';

/// "Who is playing today?" — shown after Play, before the game list.
class ProfilePickerScreen extends ConsumerStatefulWidget {
  const ProfilePickerScreen({super.key});

  @override
  ConsumerState<ProfilePickerScreen> createState() =>
      _ProfilePickerScreenState();
}

class _ProfilePickerScreenState extends ConsumerState<ProfilePickerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _twinkle = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..repeat();

  @override
  void dispose() {
    _twinkle.dispose();
    super.dispose();
  }

  void _choose(Profile profile) {
    ref.read(audioServiceProvider).playSfx('audio/sparkle.mp3');
    ref.read(currentProfileIdProvider.notifier).select(profile.id);
    context.go('/play');
  }

  Future<void> _addProfile() async {
    ref.read(audioServiceProvider).playSfx('audio/creak.mp3');
    final result = await AddProfileSheet.show(context);
    if (result == null || !mounted) return;
    final (name, avatarId) = result;
    await ref
        .read(profilesProvider.notifier)
        .add(name: name, avatarId: avatarId);
  }

  Future<void> _deleteProfile(Profile profile) async {
    final audio = ref.read(audioServiceProvider)..playSfx('audio/creak.mp3');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteDialog(name: profile.name),
    );
    if (confirmed != true || !mounted) return;
    audio.playSfx('audio/woo.mp3');
    // If this was the chosen player, the dashboard falls back to the
    // remaining player (or Boo) on its own.
    await ref.read(profilesProvider.notifier).remove(profile.id);
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(profilesProvider);
    final canAdd = !ref.read(profilesProvider.notifier).isFull;

    return Scaffold(
      backgroundColor: HalloweenColors.nightSky,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/welcome_scene.jpg',
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.2),
          ),
          const ColoredBox(color: Color(0x880E0318)),
          AnimatedBuilder(
            animation: _twinkle,
            builder: (context, _) => FireflyLayer(t: _twinkle.value),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  const Row(
                    children: [BackHomeButton(), Spacer(), MuteButton()],
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, box) => SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: box.maxHeight),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const WoodenSign(
                                message: 'Who is playing today?',
                              ),
                              const SizedBox(height: 28),
                              _ProfileGrid(
                                profiles: profiles,
                                maxWidth: box.maxWidth,
                                onTap: _choose,
                                onDelete: _deleteProfile,
                              ),
                              const SizedBox(height: 28),
                              // Stays visible at the limit, but can't be tapped.
                              MenuPillButton(
                                label: 'Add Profile',
                                icon: Icons.add_circle_rounded,
                                fill: const Color(0xFFF6C27A),
                                shadow: const Color(0xFFC98A3E),
                                foreground: HalloweenColors.parentsBrown,
                                onPressed: canAdd ? _addProfile : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileGrid extends StatelessWidget {
  const _ProfileGrid({
    required this.profiles,
    required this.maxWidth,
    required this.onTap,
    required this.onDelete,
  });

  final List<Profile> profiles;
  final double maxWidth;
  final void Function(Profile) onTap;
  final void Function(Profile) onDelete;

  static const _gap = 12.0;

  @override
  Widget build(BuildContext context) {
    final perRow = math.min(profiles.length, ProfilesNotifier.maxProfiles);
    final width = ((maxWidth - _gap * (perRow - 1)) / perRow).clamp(
      70.0,
      150.0,
    );
    return Wrap(
      spacing: _gap + 16, // room for the delete badges
      runSpacing: 18,
      alignment: WrapAlignment.center,
      children: [
        for (final p in profiles)
          ProfileCard(
            key: ValueKey(p.id),
            profile: p,
            width: width,
            onTap: () => onTap(p),
            // Boo is the placeholder, so he has no delete button.
            onDelete: p.id == Profile.booId ? null : () => onDelete(p),
          ),
      ],
    );
  }
}

class _DeleteDialog extends StatelessWidget {
  const _DeleteDialog({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AlertDialog(
      backgroundColor: HalloweenColors.castlePurple,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text('Delete $name?', style: text.headlineMedium),
      content: Text(
        'This player will be gone from this device.',
        style: text.bodyLarge,
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            minimumSize: const Size(96, 48),
            foregroundColor: HalloweenColors.cream,
            textStyle: text.titleLarge,
          ),
          child: const Text('Keep'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            minimumSize: const Size(96, 48),
            backgroundColor: HalloweenColors.orange,
            textStyle: text.titleLarge,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
