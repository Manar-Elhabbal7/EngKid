import 'package:flutter/material.dart';
import 'package:engkids/app/theme.dart';
import 'package:engkids/features/lessons/models/lesson.dart';
import 'package:engkids/shared/widgets/boo_speech.dart';
import 'package:engkids/shared/widgets/coin_counter.dart';

/// Shown when a lesson's last item is done. [bonus] is 0 when the lesson
/// was already finished before, so the bonus and "now open" lines hide.
class LessonFinishedDialog extends StatelessWidget {
  const LessonFinishedDialog({
    super.key,
    required this.lesson,
    required this.message,
    required this.bonus,
  });

  /// The lesson just finished; the one after it is announced as open.
  final Lesson lesson;

  /// e.g. "You learned all 26 letters!"
  final String message;
  final int bonus;

  static Future<void> show(
    BuildContext context, {
    required Lesson lesson,
    required String message,
    required int bonus,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          LessonFinishedDialog(lesson: lesson, message: message, bonus: bonus),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final next = lesson.index + 1 < Lesson.values.length
        ? Lesson.values[lesson.index + 1]
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
              message,
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
                  Flexible(
                    child: Text(
                      '+$bonus bonus coins',
                      style: text.titleLarge?.copyWith(
                        color: HalloweenColors.gold,
                      ),
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
