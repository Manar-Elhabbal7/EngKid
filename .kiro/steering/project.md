# Steering: EngKids — Kiroween 2026

## Project Identity
This is **EngKids**, a Flutter educational app for kids (ages 4–8) to learn English.
Category: **Costume Contest** — the defining quality bar is a polished, spooky-Halloween-themed UI that enhances every learning interaction.

## Stack
- Flutter 3.47.2 / Dart 3.13.2
- Targets: Android (primary), iOS
- Orientation: portrait AND landscape (use `OrientationBuilder` for adaptive layouts)
- State management: Riverpod
- Animation: Lottie + Flutter Animate
- Audio SFX: audioplayers
- Pronunciation / TTS: flutter_tts 4.2.5 — set language "en-US", pitch 1.1 (slightly higher = more child-friendly), rate 0.5 (slower for learners)
- Local persistence: Hive or SharedPreferences

## Code Conventions
- File names: `snake_case.dart`
- Class names: `PascalCase`
- Widget files live in `lib/features/<feature>/widgets/`
- Screen files live in `lib/features/<feature>/screens/`
- Shared widgets in `lib/shared/widgets/`
- Assets declared in `pubspec.yaml` under `assets/`
- One widget per file; keep files under 200 lines

## UI / Design Rules
- Halloween palette: deep purple (#1A0030), orange (#FF6B00), ghost white (#F5F0FF), pumpkin yellow (#FFD700)
- Rounded corners everywhere (≥16 px radius)
- Every interactive element must have a sound effect + haptic
- Minimum tap target: 48×48 dp
- Text: use a child-friendly font (Nunito or Baloo 2)
- No red error colours visible to the child — use ghost/pumpkin icons instead

## Always Do
- Run `flutter analyze` before committing
- Keep the `/.kiro` directory committed (never gitignore it)
- Write widget tests for every new screen

## Ask First
- Adding new pub.dev packages
- Changing the app's color palette
- Altering navigation structure

## Never Do
- Commit API keys or secrets
- Skip null-safety
- Use `dart:mirrors`
