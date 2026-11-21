import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'shared/services/tts_service.dart';
import 'shared/providers/progress_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow both portrait and landscape orientations.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Hide the status-bar for a more immersive Halloween feel.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialise local storage and open the progress box.
  await Hive.initFlutter();
  await openProgressBox();

  // Warm up TTS so the first word plays without a noticeable delay.
  await TtsService.instance.init();

  runApp(
    // ProviderScope is required for Riverpod.
    // Source: https://pub.dev/packages/flutter_riverpod
    const ProviderScope(child: EngKidsApp()),
  );
}

class EngKidsApp extends StatelessWidget {
  const EngKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EngKids',
      debugShowCheckedModeBanner: false,
      theme: buildHalloweenTheme(),
      routerConfig: appRouter,
    );
  }
}
