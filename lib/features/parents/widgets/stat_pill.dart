import 'package:flutter/material.dart';
import 'package:engkids/features/parents/widgets/parchment_panel.dart';

/// "Letters Learned   26" style row on the dashboard.
class StatPill extends StatelessWidget {
  const StatPill({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleLarge
        ?.copyWith(color: ParchmentColors.ink, fontSize: 18);
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: ParchmentColors.pill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x557A4A1E), width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(label, style: style),
              ),
            ),
            const SizedBox(width: 10),
            Text(value, style: style?.copyWith(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
