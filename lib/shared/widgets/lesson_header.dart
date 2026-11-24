import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:engkids/app/theme.dart';
import 'package:engkids/shared/widgets/coin_counter.dart';
import 'package:engkids/features/home/widgets/wooden_sign.dart';

/// Lesson app bar: back button · wooden title sign · coin counter.
class LessonHeader extends StatelessWidget {
  const LessonHeader({
    super.key,
    required this.title,
    required this.coins,
    required this.onBack,
  });

  final String title;

  final int coins;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Tooltip(
          message: 'Back',
          child: Semantics(
            button: true,
            label: 'Back',
            excludeSemantics: true,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onBack();
              },
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFB04A), HalloweenColors.orange],
                  ),
                  border: Border.all(color: const Color(0xFFFFE08A), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: HalloweenColors.orange.withValues(alpha: 0.45),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Center(child: WoodenSign(message: title, compact: true)),
        ),
        const SizedBox(width: 10),
        CoinCounter(coins: coins),
      ],
    );
  }
}
