import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:engkids/app/theme.dart';
import 'package:engkids/features/home/widgets/menu_pill_button.dart';
import 'package:engkids/features/parents/widgets/dashboard_profile.dart';
import 'package:engkids/features/parents/widgets/parchment_panel.dart';
import 'package:engkids/features/parents/widgets/rename_dialog.dart';
import 'package:engkids/features/parents/widgets/stat_pill.dart';
import 'package:engkids/features/parents/widgets/strength_bar.dart';
import 'package:engkids/features/profiles/models/profile.dart';
import 'package:engkids/features/profiles/providers/profiles_provider.dart';
import 'package:engkids/features/profiles/widgets/back_home_button.dart';
import 'package:engkids/features/progress/models/child_progress.dart';
import 'package:engkids/features/progress/providers/progress_provider.dart';
import 'package:engkids/shared/audio/audio_service.dart';

/// Parent Dashboard: the chosen player (or Boo if nobody is chosen) and
/// their progress.
class ParentsScreen extends ConsumerWidget {
  const ParentsScreen({super.key});

  static const _barColors = {
    Skill.alphabet: HalloweenColors.playGreen,
    Skill.vocabulary: Color(0xFF3A8FD9),
    Skill.matching: Color(0xFF3A8FD9),
    Skill.spelling: Color(0xFF3A8FD9),
  };

  Future<void> _rename(BuildContext context, WidgetRef ref, Profile p) async {
    ref.read(audioServiceProvider).playSfx('audio/creak.mp3');
    final name = await RenameDialog.show(context, p.name);
    if (name == null) return;
    final ok = await ref.read(profilesProvider.notifier).rename(p.id, name);
    if (ok) ref.read(audioServiceProvider).playSfx('audio/chime.mp3');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final progress =
        ref.watch(progressProvider)[profile.id] ?? ChildProgress.empty;
    final audio = ref.watch(audioServiceProvider);
    final isBoo = profile.id == Profile.booId;

    final header = DashboardProfile(
      profile: profile,
      onEdit: isBoo ? null : () => _rename(context, ref, profile),
    );
    final stats = Column(
      children: [
        StatPill(label: 'Letters Learned', value: '${progress.lettersLearned}'),
        const SizedBox(height: 8),
        StatPill(label: 'Words Learned', value: '${progress.wordsLearned}'),
        const SizedBox(height: 8),
        StatPill(label: 'Time Played', value: progress.timePlayedLabel),
      ],
    );
    final strengths = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Activity Strengths',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(color: ParchmentColors.ink, fontSize: 21),
        ),
        const SizedBox(height: 10),
        for (final skill in Skill.values) ...[
          StrengthBar(
            label: skill.label,
            value: progress.strength(skill),
            color: _barColors[skill]!,
          ),
          const SizedBox(height: 8),
        ],
        if (progress.isEmpty)
          Text(
            '${profile.name}\'s progress will show here after playing.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ParchmentColors.ink.withValues(alpha: 0.75),
              fontSize: 16,
            ),
          ),
      ],
    );

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
          const ColoredBox(color: Color(0x990E0318)),
          SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(children: [BackHomeButton()]),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Column(
                          children: [
                            ParchmentPanel(
                              // Width-based: inside a scroll view the
                              // height is unbounded, so orientation of the
                              // panel itself can't be measured.
                              child: LayoutBuilder(
                                builder: (context, box) => _PanelLayout(
                                  wide: box.maxWidth >= 600,
                                  header: header,
                                  stats: stats,
                                  strengths: strengths,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: MenuPillButton(
                                    label: 'Sound',

                                    icon: audio.muted
                                        ? Icons.volume_off_rounded
                                        : Icons.volume_up_rounded,
                                    fill: HalloweenColors.parentsCream,
                                    shadow: const Color(0xFFC9A36A),
                                    foreground: HalloweenColors.parentsBrown,
                                    fontSize: 16,
                                    iconSize: 20,
                                    onPressed: audio.toggleMute,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: MenuPillButton(
                                    label: 'Manage Profiles',
                                    icon: Icons.groups_rounded,
                                    fill: HalloweenColors.parentsCream,
                                    shadow: const Color(0xFFC9A36A),
                                    foreground: HalloweenColors.parentsBrown,
                                    fontSize: 16,
                                    iconSize: 20,
                                    onPressed: () {
                                      audio.playSfx('audio/creak.mp3');
                                      context.go('/profiles');
                                    },
                                  ),
                                ),
                              ],
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
        ],
      ),
    );
  }
}

/// Narrow (phones in portrait): profile + stats on top, strengths below,
/// like the mockup. Wide (landscape/tablets): all three side by side.
class _PanelLayout extends StatelessWidget {
  const _PanelLayout({
    required this.wide,
    required this.header,
    required this.stats,
    required this.strengths,
  });

  final bool wide;
  final Widget header;
  final Widget stats;
  final Widget strengths;

  @override
  Widget build(BuildContext context) {
    const divider = Divider(color: Color(0x557A4A1E), thickness: 1.5);
    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: header),
          const SizedBox(width: 16),
          Expanded(child: stats),
          const SizedBox(width: 20),
          Expanded(child: strengths),
        ],
      );
    }
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: 124, child: header),
            const SizedBox(width: 12),
            Expanded(child: stats),
          ],
        ),
        const SizedBox(height: 12),
        divider,
        const SizedBox(height: 8),
        strengths,
      ],
    );
  }
}
