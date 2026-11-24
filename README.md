# 🎃 EngKids — Halloween English Learning App

> **Kiroween 2026 Hackathon Entry** · Category: **Costume Contest**

EngKids is a Flutter app that teaches English to children aged 4–8 through five
Halloween-themed mini-games. Every interaction is wrapped in a polished spooky
UI: a deep-purple haunted mansion, pumpkin-orange glow buttons, and "Boo" the
friendly ghost mascot who guides kids through every activity.

---

## 🏚️ Features

| Activity | What kids learn |
|---|---|
| 🎃 **Alphabet Adventure** | Letters A–Z with example words and TTS pronunciation |
| 👻 **Vocabulary Haunted Forest** | 50 words across 10 categories, 3D flip-card mechanic |
| 🧩 **Word Matching** | Drag-and-drop emoji → word matching, 3 rounds |
| ❓ **Spell-It Quiz** | 4-choice word quiz, streak counter, fireworks on 5-in-a-row |
| 🫧 **Magic Cauldron** | Progress dashboard: letters / words / stars earned |

All content works **fully offline** — pronunciation uses on-device TTS
(`flutter_tts`), no audio files or internet required.

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.47.2+ (`flutter --version`)
- Android SDK or Chrome (for web)

### Run
```bash
git clone https://github.com/YOUR_USERNAME/engkids.git
cd engkids
flutter pub get
flutter run                   # Android / connected device
flutter run -d chrome         # Web
```

### Build
```bash
flutter build apk --release   # Android APK
flutter build web --release   # Web
```

### Test & Analyze
```bash
flutter test
flutter analyze
```

---

## 🗂️ Project Structure

```
lib/
  main.dart                        # Entry point, Hive init, TTS warm-up
  app/
    theme.dart                     # HalloweenTheme + HalloweenColors
    router.dart                    # GoRouter with spooky transitions
  features/
    home/                          # Haunted Mansion home screen
    alphabet/                      # Alphabet Adventure (A–Z PageView)
    vocabulary/                    # Vocabulary Haunted Forest (flip cards)
    matching/                      # Word Matching Game (drag & drop)
    quiz/                          # Spell-It Quiz (multiple choice)
    progress/                      # Magic Cauldron (progress dashboard)
  shared/
    services/                      # TtsService, AudioService
    providers/                     # Riverpod + Hive progress providers
    widgets/                       # ScaffoldWithBackground, GhostMascot,
                                   # SpookyButton, StarReward
.kiro/
  steering/project.md              # Kiro steering — conventions & rules
  specs/SPEC-engkids-v1.md         # Full V1 spec
assets/
  images/   audio/   animations/   # Asset directories (SFX to be added)
```

---

## 🛠️ How Kiro Was Used

This project was built entirely with **Kiro IDE** using spec-driven development:

- **Spec** (`.kiro/specs/SPEC-engkids-v1.md`) — written before any code,
  covering objectives, tech stack, feature list, success criteria, and what
  was explicitly deferred to V2. This made every implementation decision
  traceable and prevented scope creep.

- **Steering** (`.kiro/steering/project.md`) — defined the Halloween colour
  palette, file naming conventions, TTS settings, and "always / ask first /
  never" rules. Kiro followed these automatically across every file it touched.

- **Incremental implementation** — each phase was a separate session with its
  own analyze + test gate before moving on. No phase was marked done until
  `flutter analyze` returned zero issues and all tests passed.

- **Test-driven** — unit tests were written alongside game logic (quiz engine,
  matching game), catching a real bug (duplicate "Bat" word across categories)
  before it could affect the UI.

---

## 📋 Tech Stack

| Concern | Package |
|---|---|
| Framework | Flutter 3.47.2 / Dart 3.13.2 |
| State | flutter_riverpod 2.6.1 |
| Navigation | go_router 14.x |
| Animation | flutter_animate 4.5.2, lottie 3.x |
| Fonts | google_fonts (Baloo 2) |
| TTS | flutter_tts 4.2.5 |
| Audio SFX | audioplayers 6.x |
| Storage | hive_flutter 1.1.0 |

---

## 🙏 Credits

- **Letter voices** (`assets/audio/letters/A.mp3` … `Z.mp3`): recordings from
  [Show and Tell Letter](https://www.showandtellletter.com/letters).
- **Haunted Forest word voices** (`assets/audio/words/*.mp3`): pronunciations
  from [Forvo](https://forvo.com), recorded by Forvo community members.
  Forvo pronunciations are licensed under
  [CC BY-NC-SA 3.0](https://creativecommons.org/licenses/by-nc-sa/3.0/)
  (credit required, non-commercial use only, share-alike). These audio files
  are not covered by this project's MIT license.

## 📄 License

MIT — see [LICENSE](LICENSE).
