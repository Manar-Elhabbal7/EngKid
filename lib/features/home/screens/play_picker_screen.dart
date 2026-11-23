import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:engkids/app/theme.dart';
import 'package:engkids/features/home/widgets/mute_button.dart';
import 'package:engkids/features/home/widgets/wooden_sign.dart';

class PlayPickerScreen extends StatelessWidget {
  const PlayPickerScreen({super.key});

  static const _activities = [
    ('Alphabet Adventure', '🎃'),
    ('Haunted Forest', '👻'),
    ('Word Matching', '🧩'),
    ('Spell-It Quiz', '❓'),
    ('Magic Cauldron', '🫧'),
  ];

  @override
  Widget build(BuildContext context) {
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
                    'Boo is still decorating the rooms. Coming soon!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: HalloweenColors.cream),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _activities.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final (name, emoji) = _activities[index];
                        return _LockedActivityTile(name: name, emoji: emoji);
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

class _LockedActivityTile extends StatelessWidget {
  const _LockedActivityTile({required this.name, required this.emoji});

  final String name;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HalloweenColors.castlePurple.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(20),
      child: ListTile(
        enabled: false,
        leading: Text(emoji, style: const TextStyle(fontSize: 28)),
        title: Text(
          name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
        ),
        trailing: const Icon(Icons.lock_rounded, color: HalloweenColors.gold),
      ),
    );
  }
}
