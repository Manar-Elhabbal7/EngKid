import 'package:flutter/material.dart';

import 'package:engkids/app/theme.dart';

class WoodenSign extends StatelessWidget {
  const WoodenSign({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFC8894A), Color(0xFF8A4E22), Color(0xFF6E3A16)],
          ),
          border: Border.all(color: const Color(0xFFE8C27A), width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x88080016),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: HalloweenColors.cream,
            fontSize: 28,
            height: 1.15,
            shadows: const [
              Shadow(
                color: Color(0xAA4A2208),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
