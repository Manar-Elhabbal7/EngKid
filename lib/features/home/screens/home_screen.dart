import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:engkids/app/theme.dart';
import 'package:engkids/features/home/widgets/menu_pill_button.dart';
import 'package:engkids/features/home/widgets/mute_button.dart';
import 'package:engkids/features/home/widgets/wooden_sign.dart';
import 'package:engkids/features/splash/widgets/firefly_layer.dart';
import 'package:engkids/shared/audio/audio_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _twinkle;

  @override
  void initState() {
    super.initState();
    _twinkle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).playTheme();
    });
  }

  @override
  void dispose() {
    _twinkle.dispose();
    super.dispose();
  }

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
            alignment: const Alignment(0, -0.12),
            filterQuality: FilterQuality.high,
            semanticLabel: 'Boo the ghost waving in a Halloween forest',
          ),
          AnimatedBuilder(
            animation: _twinkle,
            builder: (context, _) => FireflyLayer(t: _twinkle.value),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.topRight,
                    child: MuteButton(),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const WoodenSign(
                                  message: "Let's learn some magic!",
                                ),
                                const SizedBox(height: 22),
                                MenuPillButton(
                                  label: 'Play',
                                  icon: Icons.play_arrow_rounded,
                                  fill: HalloweenColors.playGreen,
                                  shadow: HalloweenColors.playGreenDark,
                                  foreground: Colors.white,
                                  onPressed: () {
                                    ref
                                        .read(audioServiceProvider)
                                        .playSfx('audio/sparkle.mp3');
                                    context.go('/play');
                                  },
                                ),
                                const SizedBox(height: 14),
                                MenuPillButton(
                                  label: 'Parents',
                                  icon: Icons.groups_rounded,
                                  fill: HalloweenColors.parentsCream,
                                  shadow: const Color(0xFFC9A36A),
                                  foreground: HalloweenColors.parentsBrown,
                                  onPressed: () {
                                    ref
                                        .read(audioServiceProvider)
                                        .playSfx('audio/creak.mp3');
                                    context.go('/parents');
                                  },
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
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
