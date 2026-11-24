import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:engkids/app/router.dart';
import 'package:engkids/app/theme.dart';
import 'package:engkids/features/profiles/data/profile_store.dart';
import 'package:engkids/features/profiles/providers/profiles_provider.dart';
import 'package:engkids/features/progress/data/progress_store.dart';
import 'package:engkids/features/progress/providers/progress_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Profiles and progress are saved on the device. If storage can't be
  // opened, the app still runs with in-memory data (Boo is always there).
  ProfileStore profiles;
  ProgressStore progress;
  try {
    final box = await HiveProfileStore.openBox();
    profiles = HiveProfileStore(box);
    progress = HiveProgressStore(box);
  } catch (_) {
    profiles = MemoryProfileStore();
    progress = MemoryProgressStore();
  }
  runApp(
    ProviderScope(
      overrides: [
        profileStoreProvider.overrideWithValue(profiles),
        progressStoreProvider.overrideWithValue(progress),
      ],
      child: const EngKidsApp(),
    ),
  );
}

class EngKidsApp extends StatefulWidget {
  const EngKidsApp({super.key, this.router});

  final GoRouter? router;

  @override
  State<EngKidsApp> createState() => _EngKidsAppState();
}

class _EngKidsAppState extends State<EngKidsApp> {
  late final GoRouter _router = widget.router ?? createAppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EngKids',
      debugShowCheckedModeBanner: false,
      theme: HalloweenTheme.theme,
      routerConfig: _router,
    );
  }
}
