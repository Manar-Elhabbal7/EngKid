import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:engkids/app/router.dart';
import 'package:engkids/app/theme.dart';
import 'package:engkids/features/splash/widgets/firefly_layer.dart';
import 'package:engkids/features/splash/widgets/splash_progress.dart';
import 'package:engkids/shared/audio/audio_service.dart';

/// First screen: the haunted-mansion scene (sign, Boo and pumpkin are part of
/// `splash_scene.jpg`) with "Boo is waking up..." and a pumpkin progress bar.
/// Navigates to `/home` when the bar fills.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({
    super.key,
    this.holdFor = const Duration(milliseconds: 5000),
  });

  final Duration holdFor;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  static const _scene = 'assets/images/splash_scene.jpg';

  late final AnimationController _progress;
  late final AnimationController _twinkle;
  late final Animation<double> _fill;
  var _finished = false;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this, duration: widget.holdFor)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _finish();
      });
    _fill = CurvedAnimation(parent: _progress, curve: Curves.easeInOutCubic);
    _twinkle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage(_scene), context);
      ref.read(audioServiceProvider).playTheme();
    });
    _progress.forward();
  }

  void _finish() {
    if (_finished || !mounted) return;
    _finished = true;
    splashCompleted = true;
    context.go('/home');
  }

  @override
  void dispose() {
    _progress.dispose();
    _twinkle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: HalloweenColors.nightSky,
        body: AnimatedBuilder(
          animation: Listenable.merge([_fill, _twinkle]),
          builder: (context, _) {
            final bob = 3 * math.sin(_twinkle.value * math.pi * 2);
            return OrientationBuilder(
              builder: (context, orientation) => Stack(
                fit: StackFit.expand,
                children: [
                  _Scene(landscape: orientation == Orientation.landscape),
                  const _BottomShade(),
                  FireflyLayer(t: _twinkle.value),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(32, 0, 32, 28),
                          child: SplashProgress(value: _fill.value, bob: bob),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Portrait: the scene fills the screen, anchored to the top so the sign
/// stays visible. Landscape: a dimmed copy fills the screen and the full
/// scene sits centred on top, so the sign and pumpkin are never cropped.
class _Scene extends StatelessWidget {
  const _Scene({required this.landscape});

  final bool landscape;

  @override
  Widget build(BuildContext context) {
    const image = 'assets/images/splash_scene.jpg';
    if (!landscape) {
      return Image.asset(
        image,
        fit: BoxFit.cover,
        alignment: const Alignment(0, -0.35),
        filterQuality: FilterQuality.high,
        semanticLabel: 'EngKids haunted mansion with Boo the ghost',
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
          child: Image.asset(image, fit: BoxFit.cover),
        ),
        Image.asset(
          image,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          semanticLabel: 'EngKids haunted mansion with Boo the ghost',
        ),
      ],
    );
  }
}

/// Darkens the grass at the bottom so the text and bar stay readable.
class _BottomShade extends StatelessWidget {
  const _BottomShade();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Color(0xB30E0314)],
            stops: [0.62, 1],
          ),
        ),
      ),
    );
  }
}
