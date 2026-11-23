# EngKids — Kiroween 2026 Checklist

**Category:** Costume Contest  
**Deadline:** December 4, 2026 @ 10:00 PM UTC  
**Repo:** https://github.com/Manar-Elhabbal7/EngKid  
**Live URL:** (add web deploy URL here)

---

## 🏗️ Phase 0 — Setup
- [x] Flutter project created (`flutter create`)
- [x] `.kiro/` directory created with steering + spec
- [x] `pubspec.yaml` updated: name, description, version
- [x] All packages installed: `flutter_riverpod`, `audioplayers`, `flutter_tts`, `flutter_animate`, `lottie`, `hive_flutter`, `go_router`, `google_fonts`
- [x] `flutter pub get` runs clean
- [x] `flutter analyze` returns 0 issues
- [x] Android `minSdk` set to 21
- [x] AndroidManifest TTS query intent added
- [x] Asset directories declared in `pubspec.yaml`
- [x] 4 SFX files generated: `chime.mp3`, `woo.mp3`, `creak.mp3`, `sparkle.mp3`
- [ ] GitHub public repo created and pushed
- [ ] MIT license visible in repo About section
- [ ] `/.kiro` directory committed and NOT in `.gitignore`

---

## 🎨 Phase 1 — UI Design (Starting fresh)
- [ ] Decide on UI direction and screen layout
- [ ] `HalloweenTheme` finalized
- [ ] `ScaffoldWithBackground` widget
- [ ] `SpookyButton` widget
- [ ] `GhostMascot` widget ("Boo")
- [ ] `StarReward` widget
- [ ] `TtsService` wired up
- [ ] `AudioService` wired up
- [ ] GoRouter with all 6 routes
- [ ] `main.dart` wired: ProviderScope, theme, router

---

## 🏠 Phase 2 — Home Screen
- [ ] Haunted mansion map / room selection
- [ ] Boo mascot greeting on first open (TTS)
- [ ] 5 activity doors with icons + labels
- [ ] Staggered entrance animations
- [ ] Portrait + landscape layouts
- [ ] Navigate to each activity on tap

---

## 🎃 Phase 3 — Alphabet Adventure
- [ ] 26 pumpkin letter cards (A–Z)
- [ ] PageView navigation + arrow buttons
- [ ] Tap → TTS speaks letter + example word
- [ ] Star awarded on first visit (Hive saved)
- [ ] Progress dots + visited counter
- [ ] Portrait + landscape layouts

---

## 👻 Phase 4 — Vocabulary Haunted Forest
- [ ] 10 categories × 5 words data model
- [ ] Category selection screen
- [ ] Flip card: front = emoji, back = word
- [ ] Tap → TTS speaks the word
- [ ] Star on first word learned (Hive saved)
- [ ] Portrait + landscape layouts

---

## 🧩 Phase 5 — Word Matching Game
- [ ] `MatchingGame` model (pure Dart)
- [ ] 3 rounds × 5 pairs from vocab pool
- [ ] Drag emoji → drop on word slot
- [ ] Correct: chime SFX + Boo excited
- [ ] Wrong: woo SFX + shake + Boo sad
- [ ] Star per round, game over screen
- [ ] Portrait + landscape layouts

---

## ❓ Phase 6 — Spell-It Quiz
- [ ] `QuizEngine` model (pure Dart)
- [ ] 10 questions, 4 choices each
- [ ] Correct: chime + Boo excited
- [ ] Wrong: woo + TTS speaks correct answer
- [ ] Fireworks on 5-in-a-row streak
- [ ] Summary screen with score + grade
- [ ] Portrait + landscape layouts

---

## 🫧 Phase 7 — Progress Cauldron
- [ ] Bubbling cauldron animation
- [ ] Letters / words / stars stat bubbles
- [ ] Animated progress bars
- [ ] Boo with contextual message
- [ ] Reads from Hive via Riverpod providers
- [ ] Portrait + landscape layouts

---

## ✨ Phase 8 — Polish
- [ ] Spooky page transitions (fade + scale)
- [ ] Android splash screen (deep purple)
- [ ] App icon (Halloween themed)
- [ ] `flutter analyze` — 0 issues
- [ ] All tests pass

---

## 🧪 Phase 9 — Tests
- [ ] Widget test: home screen renders
- [ ] Widget test: alphabet screen renders
- [ ] Widget test: quiz screen shows 4 choices
- [ ] Unit test: matching game logic
- [ ] Unit test: quiz score / streak
- [ ] All tests pass: `flutter test`

---

## 🚀 Phase 10 — Submission Prep
- [ ] Deploy web or Android build
- [ ] Live URL works publicly
- [ ] GitHub repo public + MIT license
- [ ] `/.kiro` directory in repo
- [ ] README.md complete
- [ ] Demo video recorded (≤ 3 min), uploaded to YouTube
- [ ] Devpost submission form filled in
- [ ] Kiro usage write-up written

---

## 📝 Devpost Submission
- [ ] Submission form started
- [ ] Category: **Costume Contest** selected
- [ ] GitHub repo URL added
- [ ] Live app URL added
- [ ] Text description written
- [ ] Demo video URL added
- [ ] Kiro usage write-up filled in
- [ ] Bonus prizes selected:
  - [ ] Best Demo (automatic)
  - [ ] Social Blitz Prize (`#KiroweenHackathon26`)
  - [ ] Bonus Blog Prize
  - [ ] Best Ghost of Kiroween Past (if registered 2025)
  - [ ] Best Student Project (if student)
- [ ] Submitted before **December 4, 2026 @ 10:00 PM UTC** ✅

---

## 📌 Resources
- [Kiro Documentation](https://kiro.dev/docs)
- [Kiroween Discord](https://discord.gg/kiro)
- [Hackathon Rules](https://kiroween2026.devpost.com/rules)
- [Flutter Docs](https://docs.flutter.dev)
- [How to add a GitHub license](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)
