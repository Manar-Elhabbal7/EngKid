import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:engkids/app/theme.dart';
import 'package:engkids/features/alphabet/models/alphabet.dart';
import 'package:engkids/features/alphabet/widgets/boo_speech.dart';
import 'package:engkids/features/alphabet/widgets/coin_burst.dart';
import 'package:engkids/features/alphabet/widgets/letter_pumpkin.dart';
import 'package:engkids/features/home/widgets/menu_pill_button.dart';

/// Boo, his speech bubble, the letter pumpkin and the Next button.
/// Portrait follows the mockup; landscape puts the three side by side.
class AlphabetStage extends StatelessWidget {
  const AlphabetStage({
    super.key,
    required this.wide,
    required this.letter,
    required this.number,
    required this.bubble,
    required this.speaking,
    required this.heard,
    required this.isLast,
    required this.burstId,
    required this.burstCoins,
    required this.onPumpkinTap,
    required this.onNext,
  });

  final bool wide;
  final AlphabetLetter letter;
  final int number;
  final String bubble;
  final bool speaking;

  /// Whether this child has already heard [letter]; Next waits for it.
  final bool heard;
  final bool isLast;
  final int burstId;
  final int burstCoins;
  final VoidCallback onPumpkinTap;
  final VoidCallback onNext;

  Widget _pumpkin(double size) => Stack(
    clipBehavior: Clip.none,
    alignment: Alignment.topCenter,
    children: [
      LetterPumpkin(
        letter: letter,
        size: size,
        speaking: speaking,
        onTap: onPumpkinTap,
      ),
      if (burstId > 0)
        // left/right keep the burst's width bounded to the pumpkin.
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

  Widget _controls(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      MenuPillButton(
        label: isLast ? 'Finish' : 'Next',
        icon: isLast ? Icons.emoji_events_rounded : Icons.arrow_forward_rounded,
        fill: HalloweenColors.playGreen,
        shadow: HalloweenColors.playGreenDark,
        foreground: Colors.white,
        fontSize: 26,
        // Disabled (dimmed) until the letter has been heard.
        onPressed: heard ? onNext : null,
      ),
      const SizedBox(height: 6),
      Text(
        '$number / ${Alphabet.letters.length}',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: HalloweenColors.cream,
          fontSize: 18,
          shadows: const [Shadow(color: Color(0xCC1A0030), blurRadius: 6)],
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        if (wide) {
          final pumpkin = math.min(box.maxHeight * 0.85, box.maxWidth * 0.38);
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
              Expanded(flex: 4, child: Center(child: _pumpkin(pumpkin))),
              Expanded(flex: 3, child: Center(child: _controls(context))),
            ],
          );
        }
        final pumpkin = math.min(box.maxWidth * 0.62, box.maxHeight * 0.52);
        return Column(
          children: [
            const Spacer(),
            Align(
              alignment: const Alignment(-0.3, 0),
              child: SpeechBubble(text: bubble),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: FloatingBoo(size: box.maxWidth * 0.36),
                ),
                Expanded(flex: 6, child: Center(child: _pumpkin(pumpkin))),
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
