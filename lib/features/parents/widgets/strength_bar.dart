import 'package:flutter/material.dart';
import 'package:engkids/features/parents/widgets/parchment_panel.dart';

/// One "Activity Strengths" row: skill name and a rounded fill bar.
class StrengthBar extends StatelessWidget {
  const StrengthBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;

  /// 0.0 – 1.0.
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return Semantics(
      label: '$label strength',
      value: '${(v * 100).round()} percent',
      excludeSemantics: true,
      child: Row(
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: ParchmentColors.ink, fontSize: 17),
            ),
          ),
          Expanded(
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: ParchmentColors.track,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x667A4A1E)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    widthFactor: v,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.lerp(color, Colors.white, 0.3)!,
                            color,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
