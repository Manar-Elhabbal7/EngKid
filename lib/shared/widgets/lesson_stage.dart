import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:engkids/shared/widgets/boo_speech.dart';
import 'package:engkids/shared/widgets/coin_burst.dart';
import 'package:engkids/shared/widgets/lesson_next_controls.dart';

/// Layout shared by the lessons: Boo with his speech bubble, the lesson's
/// main picture ([prop]), the "+5" coin burst, and the Next button.
/// Portrait follows the Alphabet mockup; landscape puts them side by side.
class LessonStage extends StatelessWidget {
  const LessonStage({
    super.key,
    required this.wide,
    required this.prop,
    required this.number,
    required this.total,
    required this.bubble,
    required this.heard,
    required this.isLast,
    required this.burstId,
    required this.burstCoins,
    required this.onNext,
    this.onPrev,
  });

  final bool wide;

  /// Builds the pumpkin / card at the given size.
  final Widget Function(double size) prop;
  final int number;
  final int total;
  final String bubble;

  /// Whether the current item was heard; Next waits for it.
  final bool heard;
  final bool isLast;
  final int burstId;
  final int burstCoins;
  final VoidCallback onNext;

  /// Goes back one item; null on the first item.
  final VoidCallback? onPrev;

  Widget _prop(double size) => Stack(
    clipBehavior: Clip.none,
    alignment: Alignment.topCenter,
    children: [
      prop(size),
      if (burstId > 0)
        // left/right keep the burst's width bounded to the prop.
        Positioned(
          top: size * 0.1,
          left: 0,
          right: 0,
          child: Center(
            child: CoinBurst(key: ValueKey(burstId), amount: burstCoins),
          ),
        ),
    ],
  );

  Widget _controls(BuildContext context) => LessonNextControls(
    isLast: isLast,
    // Disabled (dimmed) until the current item has been heard.
    enabled: heard,
    counter: '$number / $total',
    onNext: onNext,
    onPrev: onPrev,
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        if (wide) {
          final size = math.min(box.maxHeight * 0.85, box.maxWidth * 0.38);
          return Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpeechBubble(text: bubble),
                    FloatingBoo(size: math.min(box.maxHeight * 0.45, 180)),
                  ],
                ),
              ),
              Expanded(flex: 4, child: Center(child: _prop(size))),
              Expanded(flex: 3, child: Center(child: _controls(context))),
            ],
          );
        }
        final size = math.min(box.maxWidth * 0.62, box.maxHeight * 0.52);
        return Column(
          children: [
            const Spacer(),
            Align(
              alignment: const Alignment(-0.3, 0),
              child: SpeechBubble(text: bubble),
            ),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: FloatingBoo(size: box.maxWidth * 0.36),
                ),
                Expanded(flex: 6, child: Center(child: _prop(size))),
              ],
            ),
            const Spacer(),
            _controls(context),
          ],
        );
      },
    );
  }
}
