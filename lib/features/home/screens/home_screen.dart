import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:engkids/app/theme.dart';
import 'package:engkids/features/home/widgets/menu_pill_button.dart';
import 'package:engkids/features/home/widgets/mute_button.dart';
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
          const _WelcomeScene(),
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
                                    context.go('/profiles');
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

/// Tall screens (phones): the scene fills the screen, as before.
/// Wide screens (web, landscape): a dimmed copy fills the screen and the
/// whole scene sits centred on top, so Boo and the sign aren't zoomed in
/// and cut off. Same approach as the splash screen.
class _WelcomeScene extends StatelessWidget {
  const _WelcomeScene();

  static const _image = 'assets/images/welcome_scene.jpg';
  static const _label = 'Boo the ghost waving in a Halloween forest';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        if (box.maxWidth <= box.maxHeight) {
          return Image.asset(
            _image,
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.12),
            filterQuality: FilterQuality.high,
            semanticLabel: _label,
          );
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Color(0x99120418),
                BlendMode.srcATop,
              ),
              child: Image.asset(
                _image,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
              ),
            ),
            Image.asset(
              _image,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              semanticLabel: _label,
            ),
          ],
        );
      },
    );
  }
}
