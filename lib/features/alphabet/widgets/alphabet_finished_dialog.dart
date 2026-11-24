import 'package:flutter/material.dart';
import 'package:engkids/app/theme.dart';
import 'package:engkids/features/alphabet/widgets/boo_speech.dart';
import 'package:engkids/features/alphabet/widgets/coin_counter.dart';
import 'package:engkids/features/lessons/models/lesson.dart';

/// Shown after the last letter. [bonus] is 0 when the alphabet was already
/// finished before, so the bonus line and "now open" line are hidden.
class AlphabetFinishedDialog extends StatelessWidget {
  const AlphabetFinishedDialog({super.key, required this.bonus});

  final int bonus;

  static Future<void> show(BuildContext context, int bonus) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlphabetFinishedDialog(bonus: bonus),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final next = Lesson.alphabet.index + 1 < Lesson.values.length
        ? Lesson.values[Lesson.alphabet.index + 1]
        : null;
    return Dialog(
      backgroundColor: HalloweenColors.castlePurple,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FloatingBoo(size: 120),
            const SizedBox(height: 8),
            Text(
              'You learned all 26 letters!',
              textAlign: TextAlign.center,
              style: text.headlineMedium?.copyWith(fontSize: 26),
            ),
            if (bonus > 0) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CoinImage(size: 36),
                  const SizedBox(width: 8),
                  Text(
                    '+$bonus bonus coins',
                    style: text.titleLarge?.copyWith(
                      color: HalloweenColors.gold,
                    ),
                  ),
                ],
              ),
              if (next != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${next.emoji} ${next.title} is now open!',
                  textAlign: TextAlign.center,
                  style: text.bodyLarge,
                ),
              ],
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: HalloweenColors.playGreen,
                foregroundColor: Colors.white,
                textStyle: text.titleLarge?.copyWith(fontSize: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: const Text('Back to games'),
            ),
          ],
        ),
      ),
    );
  }
}
