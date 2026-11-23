import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:engkids/app/theme.dart';
import 'package:engkids/features/home/widgets/mute_button.dart';
import 'package:engkids/features/home/widgets/wooden_sign.dart';

class ParentsScreen extends StatelessWidget {
  const ParentsScreen({super.key});

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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton.filled(
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
                      ),
                      const Spacer(),
                      const MuteButton(),
                    ],
                  ),
                  const Spacer(),
                  const WoodenSign(message: "Parents' corner"),
                  const SizedBox(height: 16),
                  Text(
                    'Profiles and progress will live here. Coming soon!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: HalloweenColors.cream, fontSize: 22),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
