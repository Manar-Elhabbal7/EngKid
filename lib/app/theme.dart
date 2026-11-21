import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Halloween colour palette used throughout EngKids.
abstract final class HalloweenColors {
  static const deepPurple = Color(0xFF1A0030);
  static const midPurple = Color(0xFF2D0050);
  static const pumpkinOrange = Color(0xFFFF6B00);
  static const pumpkinYellow = Color(0xFFFFD700);
  static const ghostWhite = Color(0xFFF5F0FF);
  static const spookyGreen = Color(0xFF39D353);
  static const bloodRed = Color(0xFFCC0000); // used only for internal errors, never shown to child
  static const starGold = Color(0xFFFFCC00);
}

/// Builds the app-wide [ThemeData].
ThemeData buildHalloweenTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: HalloweenColors.pumpkinOrange,
      onPrimary: HalloweenColors.ghostWhite,
      secondary: HalloweenColors.pumpkinYellow,
      onSecondary: HalloweenColors.deepPurple,
      surface: HalloweenColors.midPurple,
      onSurface: HalloweenColors.ghostWhite,
      error: HalloweenColors.bloodRed,
    ),
    scaffoldBackgroundColor: HalloweenColors.deepPurple,
  );

  return base.copyWith(
    textTheme: GoogleFonts.baloo2TextTheme(base.textTheme).apply(
      bodyColor: HalloweenColors.ghostWhite,
      displayColor: HalloweenColors.ghostWhite,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: HalloweenColors.pumpkinOrange,
        foregroundColor: HalloweenColors.ghostWhite,
        textStyle: GoogleFonts.baloo2(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        minimumSize: const Size(48, 56),
        elevation: 6,
        shadowColor: HalloweenColors.pumpkinOrange.withValues(alpha: 0.6),
      ),
    ),
    cardTheme: CardThemeData(
      color: HalloweenColors.midPurple,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: HalloweenColors.pumpkinOrange,
          width: 2,
        ),
      ),
      elevation: 8,
    ),
  );
}
