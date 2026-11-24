import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:engkids/app/theme.dart';
import 'package:engkids/features/home/widgets/mute_button.dart';
import 'package:engkids/features/home/widgets/wooden_sign.dart';
import 'package:engkids/features/lessons/models/lesson.dart';
import 'package:engkids/features/profiles/providers/profiles_provider.dart';
import 'package:engkids/features/progress/models/child_progress.dart';
import 'package:engkids/features/progress/providers/progress_provider.dart';
import 'package:engkids/shared/audio/audio_service.dart';

class PlayPickerScreen extends ConsumerWidget {
  const PlayPickerScreen({super.key});

  /// Where each open lesson leads. Lessons without a screen yet aren't listed.
  static const _routes = {
    Lesson.alphabet: '/play/alphabet',
    Lesson.forest: '/play/forest',
    Lesson.matching: '/play/matching',
  };

  void _open(BuildContext context, WidgetRef ref, Lesson lesson) {
    final route = _routes[lesson];
    if (route == null) return;
    ref.read(audioServiceProvider).playSfx('audio/sparkle.mp3');
    context.go(route);
  }

  void _explainLocked(BuildContext context, WidgetRef ref, Lesson lesson) {
    HapticFeedback.heavyImpact();
    ref.read(audioServiceProvider).playSfx('audio/woo.mp3');
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: HalloweenColors.castlePurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            const Icon(Icons.lock_rounded, color: HalloweenColors.gold),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Finish ${lesson.previous!.title} first!',
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: HalloweenColors.cream),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final progress =
        ref.watch(progressProvider)[profile.id] ?? ChildProgress.empty;

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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  const Row(children: [_BackButton(), Spacer(), MuteButton()]),
                  const SizedBox(height: 12),
                  const WoodenSign(message: 'Choose a game'),
                  const SizedBox(height: 8),
                  Text(
                    'Finish each lesson to open the next one!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: HalloweenColors.cream),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: Lesson.values.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final lesson = Lesson.values[index];
                        final open = lesson.isUnlocked(
                          progress.completedLessons,
                        );
                        return _LessonTile(
                          lesson: lesson,
                          unlocked: open,
                          onTap: open
                              ? () => _open(context, ref, lesson)
                              : () => _explainLocked(context, ref, lesson),
                        );
                      },
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

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      style: IconButton.styleFrom(
        backgroundColor: HalloweenColors.castlePurple,
        foregroundColor: HalloweenColors.cream,
        minimumSize: const Size(48, 48),
      ),
      tooltip: 'Back',
      onPressed: () {
        HapticFeedback.lightImpact();
        context.go('/home');
      },
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }
}

/// One lesson row. Open lessons are bright with a play icon; locked ones
/// are dimmed with a lock, but still tappable so the child hears why.
class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.lesson,
    required this.unlocked,
    required this.onTap,
  });

  final Lesson lesson;
  final bool unlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cream = HalloweenColors.cream.withValues(alpha: unlocked ? 1 : 0.55);
    return Semantics(
      button: true,
      label: '${lesson.title}, ${unlocked ? 'open' : 'locked'}',
      excludeSemantics: true,
      child: Material(
        color: HalloweenColors.castlePurple.withValues(
          alpha: unlocked ? 0.95 : 0.7,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: unlocked
              ? const BorderSide(color: HalloweenColors.gold, width: 2)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          minTileHeight: 64,
          onTap: () {
            if (unlocked) HapticFeedback.mediumImpact();
            onTap();
          },
          leading: Opacity(
            opacity: unlocked ? 1 : 0.55,
            child: Text(lesson.emoji, style: const TextStyle(fontSize: 28)),
          ),
          title: Text(
            lesson.title,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontSize: 20, color: cream),
          ),
          trailing: unlocked
              ? const Icon(
                  Icons.play_circle_fill_rounded,
                  color: HalloweenColors.playGreen,
                  size: 34,
                )
              : const Icon(Icons.lock_rounded, color: HalloweenColors.gold),
        ),
      ),
    );
  }
}
