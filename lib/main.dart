import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:engkids/app/router.dart';
import 'package:engkids/app/theme.dart';
import 'package:engkids/features/profiles/data/profile_store.dart';
import 'package:engkids/features/profiles/providers/profiles_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Profiles are saved on the device. If storage can't be opened, the app
  // still runs with in-memory profiles (Boo is always available).
  ProfileStore store;
  try {
    store = await HiveProfileStore.open();
  } catch (_) {
    store = MemoryProfileStore();
  }
  runApp(
    ProviderScope(
      overrides: [profileStoreProvider.overrideWithValue(store)],
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
