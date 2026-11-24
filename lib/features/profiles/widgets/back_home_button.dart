import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:engkids/app/theme.dart';

/// Round back button that returns to the home screen.
class BackHomeButton extends StatelessWidget {
  const BackHomeButton({super.key});

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
