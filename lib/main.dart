import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:engkids/app/router.dart';
import 'package:engkids/app/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: EngKidsApp()));
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
