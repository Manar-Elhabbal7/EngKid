# Spec: EngKids — V1

## Objective
Build **EngKids**, a Halloween-themed English-learning app for children aged 4–8.
The app teaches English vocabulary, letters, and simple phrases through five mini-games, each wrapped in a playful spooky Halloween UI.
Success = a child can open the app and independently complete a learning activity in under 60 seconds, guided purely by visual and audio cues (no reading required to navigate).

**Category:** Costume Contest — judged heavily on UI polish, Halloween atmosphere, and coherence.

## User
Primary: children ages 4–8 who are beginner English learners.
Secondary: parents/guardians who may set up and monitor progress.

## Tech Stack
| Concern | Choice |
|---|---|
| Framework | Flutter 3.47.2 |
| Language | Dart 3.13.2 |
| State | Riverpod 2.x |
| Animation | flutter_animate + Lottie |
| Audio SFX | audioplayers 6.x |
| TTS / Pronunciation | flutter_tts 4.2.5 (on-device, no internet needed) |
| Storage | Hive 2.x (local progress) |
| Fonts | Google Fonts: Baloo 2 |
| Platforms | Android (primary), iOS |
| Orientation | Portrait + Landscape (both supported) |

## Commands
```
Dev:      flutter run
Build:    flutter build apk --release
Web:      flutter build web --release
Test:     flutter test
Analyze:  flutter analyze
Format:   dart format lib/
```

## Project Structure
```
lib/
  main.dart                    # App entry, theme, providers
  app/
    router.dart                # GoRouter routes
    theme.dart                 # HalloweenTheme
  features/
    home/
      screens/home_screen.dart  # Haunted mansion map
    alphabet/
      screens/alphabet_screen.dart
      widgets/letter_card.dart
    vocabulary/
      screens/vocab_screen.dart
      widgets/word_card.dart
    matching/
      screens/matching_screen.dart
    quiz/
      screens/quiz_screen.dart
    progress/
      screens/progress_screen.dart
  shared/
    widgets/
      spooky_button.dart
      ghost_mascot.dart
      star_reward.dart
      scaffold_with_bg.dart
    audio/audio_service.dart
    models/lesson.dart
assets/
  images/      # PNG/SVG scene art
  audio/       # Word pronunciations + SFX
  animations/  # Lottie JSON (ghost, pumpkin, stars)
  fonts/       # Baloo2 TTF
.kiro/
  steering/project.md
  specs/SPEC-engkids-v1.md
  hooks/
tasks/
  plan.md
  todo.md
```

## Core Features (V1 Scope)

### 1. Haunted Mansion Home Screen
- Illustrated Halloween mansion as a map; each room = one learning activity
- Ghost mascot "Boo" waves and says a greeting in English when the app opens
- Animated pumpkins and floating ghosts in the background
- 5 room doors, each with a lock icon until the previous is completed

### 2. Alphabet Adventure (Letters A–Z)
- Each letter shown as a carved pumpkin with a letter on it
- Tap a pumpkin → big letter, picture of a word starting with that letter, audio pronunciation
- Swipe left/right to navigate letters
- Stars collected for each letter visited

### 3. Vocabulary Haunted Forest (10 categories, 5 words each)
- Categories: Animals, Colors, Numbers, Body Parts, Halloween, Fruits, Shapes, Family, Weather, Actions
- Flashcard style: image on front, word on back (flip animation)
- Tap the card → hear the word pronounced
- "Trick or Treat" reveal mechanic: shake the phone or tap a cauldron to flip

### 4. Word Matching Game
- Drag the Halloween-themed image to its matching word
- 5 pairs per round, randomly drawn from the vocabulary pool
- Correct match: sparkle + sound effect; Wrong match: ghost shakes its head
- 3 rounds to earn a star badge

### 5. Spell-It Quiz
- Show an image, present 4 letter choices (or word choices for older kids)
- Multiple-choice format, big touch targets
- Encouraging ghost mascot reacts to right/wrong answers
- Track score, show fireworks on 5-in-a-row correct streak

### 6. Progress Cauldron
- Bubbling cauldron shows how many letters learned, words learned, stars earned
- Simple bar showing today's vs. total progress (no account needed)

## UI Design Language
- **Background:** Deep space-purple gradient with animated floating ghosts and bats (Lottie)
- **Buttons:** Rounded pumpkin-orange with glow shadow; haptic feedback on press
- **Cards:** Ghost-white with purple border, slight float animation
- **Typography:** Baloo 2, large (min 18 sp body), high contrast
- **Mascot:** "Boo" the friendly ghost appears on every screen, reacts contextually
- **Sounds:** Every correct action plays a cheerful chime; every wrong action plays a soft "wooo" ghost sound; navigation plays a subtle creak

## Testing Strategy
- Widget tests for each screen (at minimum: renders without error, key elements present)
- Unit tests for game logic (quiz scoring, matching correctness)
- Manual test on Android emulator and Chrome (web)
- No golden tests required for V1

## Boundaries
- **Always:** `flutter analyze` clean before commit; keep `/.kiro` committed
- **Ask first:** New packages, palette changes, adding a 6th activity
- **Never:** Internet-required gameplay (all content offline); scary/horror content (kid-safe only); ads

## Success Criteria
- [ ] App launches on Android and Web without errors
- [ ] All 5 learning activities are playable end-to-end
- [ ] Ghost mascot appears on every screen
- [ ] All vocabulary audio plays correctly
- [ ] Progress is saved between app restarts
- [ ] `flutter analyze` returns zero issues
- [ ] UI screenshots show clear Halloween atmosphere with polished design
- [ ] Demo video under 3 minutes showing all 5 activities

## Out of Scope (Deferred — V2)
- User accounts / cloud sync
- Parent dashboard with detailed analytics
- Multiplayer or classroom mode
- Languages other than English
- In-app purchases
- Push notifications / daily reminders
- More than 26 letters / 50 vocabulary words

## Open Questions
- ~~Should the app support landscape orientation, or portrait only?~~ **Resolved: both portrait and landscape.**
- ~~Do you want real recorded child-friendly audio, or TTS?~~ **Resolved: flutter_tts (on-device TTS, no audio files needed).**
- ~~Should web be the primary demo target?~~ **Resolved: Android is the primary target.**
