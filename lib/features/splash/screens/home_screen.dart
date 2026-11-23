import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:engkids/app/theme.dart';
import 'package:engkids/features/splash/widgets/firefly_layer.dart';
import 'package:engkids/features/splash/widgets/splash_progress.dart';
import 'package:engkids/shared/audio/audio_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({
    super.key,
    this.holdFor = const Duration(milliseconds: 3400),
  });

  final Duration holdFor;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _progress;
  late final AnimationController _twinkle;
  late final Animation<double> _fill;
  var _finished = false;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this, duration: widget.holdFor)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _finish();
        }
      });
    _fill = CurvedAnimation(parent: _progress, curve: Curves.easeInOutCubic);
    _twinkle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).playTheme();
    });
    _progress.forward();
  }

  Future<void> _finish() async {
    if (_finished || !mounted) return;
    _finished = true;
    if (!mounted) return;
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
            final bounce = 3.2 * math.sin(_twinkle.value * math.pi * 2);
            return Stack(
              fit: StackFit.expand,
              children: [
                const DecoratedBox(
                  decoration: BoxDecoration(color: HalloweenColors.nightSky),
                ),
                Image.asset(
                  'assets/images/splash_scene.jpg',
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, -0.08),
                  filterQuality: FilterQuality.high,
                  semanticLabel: 'EngKids haunted mansion with Boo the ghost',
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x33080016),
                        Colors.transparent,
                        Color(0xCC100318),
                      ],
                      stops: [0, 0.48, 1],
                    ),
                  ),
                ),
                FireflyLayer(t: _twinkle.value),
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
                      child: SplashProgress(
                        value: _fill.value,
                        bob: bounce - 2,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
