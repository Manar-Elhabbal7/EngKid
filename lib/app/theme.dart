import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HalloweenColors {
  HalloweenColors._();

  static const deepPurple = Color(0xFF1A0030);
  static const nightSky = Color(0xFF120418);
  static const castlePurple = Color(0xFF2A1450);
  static const orange = Color(0xFFFF6B00);
  static const pumpkin = Color(0xFFFF8A1A);
  static const gold = Color(0xFFFFD700);
  static const ghostWhite = Color(0xFFF5F0FF);
  static const cream = Color(0xFFFFF3D6);
  static const barTrack = Color(0xFF2B1420);
  static const playGreen = Color(0xFF4ED15A);
  static const playGreenDark = Color(0xFF2F9A3C);
  static const parentsCream = Color(0xFFF6E6C4);
  static const parentsBrown = Color(0xFF7A4A1E);
  static const muteOrange = Color(0xFFF0A020);
}

class HalloweenTheme {
  HalloweenTheme._();

  static ThemeData get theme {
    const textTheme = TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Baloo2',
        fontWeight: FontWeight.w800,
        color: HalloweenColors.cream,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Baloo2',
        fontWeight: FontWeight.w700,
        color: HalloweenColors.cream,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Baloo2',
        fontWeight: FontWeight.w700,
        color: HalloweenColors.cream,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Baloo2',
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: HalloweenColors.ghostWhite,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Baloo2',
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: HalloweenColors.ghostWhite,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Baloo2',
      scaffoldBackgroundColor: HalloweenColors.deepPurple,
      colorScheme: const ColorScheme.dark(
        primary: HalloweenColors.orange,
        secondary: HalloweenColors.gold,
        surface: HalloweenColors.castlePurple,
        onPrimary: HalloweenColors.ghostWhite,
        onSurface: HalloweenColors.ghostWhite,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }
}
