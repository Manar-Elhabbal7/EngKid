# EngKids — Kiroween 2026 Checklist

**Category:** Costume Contest  
**Deadline:** December 4, 2026 @ 10:00 PM UTC  
**Repo:** (a[dd GitHub URL here](https://github.com/Manar-Elhabbal7/EngKid))
**Live URL:** (add web deploy URL here)

---

## 🏗️ Phase 0 — Setup
- [x] Flutter project created (`flutter create`)
- [x] `.kiro/` directory created with steering + spec
- [x] `pubspec.yaml` updated: name, description, version
- [x] Add packages: `flutter_riverpod`, `audioplayers`, `flutter_tts`, `flutter_animate`, `lottie`, `hive_flutter`, `go_router`, `google_fonts`
- [x] `flutter pub get` runs clean
- [x] `flutter analyze` returns 0 issues
- [x] Android `minSdk` set to 21 (required by flutter_tts)
- [x] `AndroidManifest.xml` — TTS service query intent added
- [ ] GitHub public repo created with an **open-source license** (MIT recommended)
- [ ] Repo pushed and license visible in About section
- [ ] `/.kiro` directory committed and NOT in `.gitignore`
- [ ] Add assets directories to `pubspec.yaml` (`assets/images/`, `assets/audio/`, `assets/animations/`) ← already done

---

## 🎨 Phase 1 — Foundation & Theme
- [x] `HalloweenTheme` defined in `lib/app/theme.dart` (colors, fonts, button styles)
- [x] `ScaffoldWithBackground` shared widget with animated purple-gradient background — uses `OrientationBuilder` for portrait/landscape layout
- [x] Baloo 2 font loaded and applied globally via `GoogleFonts.baloo2TextTheme`
- [x] `SpookyButton` widget with orange glow + haptic feedback
- [x] `GhostMascot` widget ("Boo") that accepts an expression enum (happy/sad/thinking/excited/waving)
- [x] `TtsService` singleton: wraps flutter_tts, language="en-US", pitch=1.1, rate=0.45
- [x] `AudioService` singleton: plays SFX via audioplayers (chime, wooo, creak, sparkle)
- [x] `StarReward` widget with sparkle animation
- [x] GoRouter setup with named routes for all 6 screens
- [x] `main.dart` wired: ProviderScope, HalloweenTheme, router, Hive init, TTS warm-up, orientation unlock
- [x] Widget test passes (`flutter test`)

---

## 🏠 Phase 2 — Home Screen (Haunted Mansion)
- [x] `ActivityRoom` data model — 5 rooms with emoji, label, route, colour, description
- [x] `RoomDoor` widget — glowing card with press-scale animation + completion star badge
- [x] Haunted Mansion header with pumpkin-yellow glowing title
- [x] Boo mascot with waving expression + speech bubble
- [x] 2-column door grid for all 5 activities (last door centred)
- [x] Portrait layout: header → Boo → door grid (scrollable)
- [x] Landscape layout: Boo on the left, door grid on the right
- [x] Tap a door → plays creak SFX → navigates to activity screen
- [x] Welcome TTS greeting fires on first open ("Hi! I'm Boo! Let's learn English!")
- [x] Staggered door entrance animations (fade + slide up, 120 ms per door)
- [x] 3 widget tests pass

---

## 🎃 Phase 3 — Alphabet Adventure (A–Z)
- [x] `LetterEntry` data model — 26 entries each with letter, word, emoji, TTS phrase
- [x] `PumpkinLetterCard` widget — orange gradient card with pumpkin texture lines, big letter, bouncing emoji, word chip, tap-to-hear hint
- [x] `AlphabetScreen` — `PageView` of 26 cards, swipe or arrow nav
- [x] Tap card → TTS speaks "X is for Word" → Boo reacts (excited → happy)
- [x] First visit to a letter → star awarded, sparkle SFX, "+1 ⭐" overlay
- [x] Progress dots (26 animated pills, active one expands)
- [x] Counter chips: letters visited / 26, total stars
- [x] Portrait layout: top bar → PageView → dots → nav → Boo
- [x] Landscape layout: Boo + stats on left, PageView + nav on right
- [x] Progress saved to Hive via `visitedLettersProvider` + `totalStarsProvider`
- [x] `flutter analyze` — 0 issues
- [x] All 3 tests pass

---

## 👻 Phase 4 — Vocabulary Haunted Forest
- [x] `VocabWord` + `VocabCategory` data models — 10 categories × 5 words = 50 entries, all with emoji + TTS phrase
- [x] `CategorySelectionScreen` — 2-column cauldron grid, bubbling emoji animation, staggered entrance
- [x] `VocabFlipCard` widget — 3D Y-axis flip (480 ms), front = emoji + "Trick or Treat?", back = word + category chip
- [x] Tap front → flip + TTS speaks the word + star awarded on first learn
- [x] Tap back (already flipped) → TTS speaks the word again
- [x] Swipe / arrow navigation between the 5 cards per category
- [x] Star overlay burst on first word learned ("New word! +1 ⭐")
- [x] Progress tracked via `learnedWordsProvider` → Hive
- [x] Portrait layout: top bar → PageView → nav → Boo
- [x] Landscape layout: Boo + stats panel left, PageView + nav right
- [x] Back button returns to category selection
- [x] `flutter analyze` — 0 issues
- [x] All 3 tests pass

---

## 🧩 Phase 5 — Word Matching Game
- [x] `MatchPair`, `MatchingRound`, `MatchingGameFactory` pure-Dart models
- [x] 3 rounds × 5 pairs drawn from deduped vocab pool (no word appears twice)
- [x] `EmojiTile` — `Draggable<String>` with ghost-opacity child-when-dragging, orange glow on lift; shake animation on wrong drop
- [x] `WordSlot` — `DragTarget<String>` with animated border: neutral → yellow hover → green correct → orange wrong
- [x] Correct match: green slot + chime SFX + TTS speaks the word + Boo excited
- [x] Wrong match: shake emoji + shake slot + "wooo" SFX + Boo sad → resets after 700 ms
- [x] Round complete panel: star burst + "+1 star" + "Next Round" button
- [x] 3-round pip progress indicator in header
- [x] Game over screen: Boo excited, replay + go home buttons
- [x] Portrait layout: header → Boo → emoji/word columns
- [x] Landscape layout: Boo sidebar left, match area right
- [x] Stars saved via `totalStarsProvider` (1 per round)
- [x] `flutter analyze` — 0 issues
- [x] 10 / 10 tests pass (6 unit + 3 widget + 1 more)

---

## ❓ Phase 6 — Spell-It Quiz
- [x] `QuizQuestion` + `QuizEngine` pure-Dart model — deduped pool, 4 choices per question (1 correct + 3 distractors), score + streak + maxStreak tracking
- [x] `AnswerButton` widget — idle / correct (green glow) / wrong (orange shake) states, staggered entrance animation, 56 dp min height
- [x] `FireworksOverlay` widget — 40 coloured particles burst + "🔥 5 in a row!" banner on 5-streak
- [x] Emoji prompt card shown for each question (scales in on each new question)
- [x] 4-choice answer grid — tapping reveals correct (green ✅) + wrong (red ❌), then auto-advances after 1.2 s
- [x] Wrong answer: Boo sad + woo SFX + TTS speaks the correct answer
- [x] Correct answer: Boo excited + chime SFX
- [x] Streak badge appears at ≥ 2 correct in a row
- [x] Fireworks shown on every 5-in-a-row streak
- [x] Star awarded every 5 correct answers via `totalStarsProvider`
- [x] Summary screen: grade label, correct/total, best streak, Boo excited, replay + go home
- [x] Portrait layout: top bar → emoji → streak → answer grid → Boo
- [x] Landscape layout: emoji + Boo on left, answers on right
- [x] `flutter analyze` — 0 issues
- [x] 18 / 18 tests pass (7 quiz unit + 5 matching unit + 3 widget + 3 more)

---

## 🫧 Phase 7 — Progress Cauldron
- [x] `BubblingCauldron` widget — 🪄 cauldron with 5 rising green bubble particles (looped, staggered)
- [x] `HalloweenProgressBar` widget — animated glowing fill bar with emoji + label + count chip
- [x] Three stat bubbles: Letters 🎃 / Words 👻 / Stars ⭐ — elastic scale-in entrance, staggered
- [x] "Learning Journey" panel with letters and words progress bars (animated fill)
- [x] Star section: `StarReward` + motivational message
- [x] Boo mascot with contextual message based on progress level
- [x] Portrait layout: header → cauldron + stat bubbles → progress bars → star section → Boo
- [x] Landscape layout: cauldron + Boo left, progress bars + stars right
- [x] All data reads from Riverpod providers backed by Hive
- [x] `flutter analyze` — 0 issues

---

## ✨ Phase 8 — Polish & Costume Contest Quality
- [x] GoRouter spooky page transition: fade + scale (0.94→1.0, 420 ms) on every route
- [x] Android splash screen: deep purple #1A0030 (light + dark + API 21+ variants)
- [x] `README.md` — setup instructions, feature table, project structure, Kiro usage write-up, tech stack
- [x] `LICENSE` — MIT license (required for hackathon open-source rule)
- [x] `flutter analyze` — 0 issues
- [x] 18 / 18 tests pass
- [ ] App icon: custom Halloween icon (pumpkin/ghost — replace mipmap assets)
- [ ] Add SFX audio files to `assets/audio/` (chime.mp3, woo.mp3, creak.mp3, sparkle.mp3)
- [ ] Test on Android emulator API 33+
- [ ] Test on Chrome (web build)

---

## 🧪 Phase 9 — Tests
- [x] Widget test: app builds and shows mansion header
- [x] Widget test: home screen shows all 5 activity room labels
- [x] Widget test: home screen shows Boo mascot
- [x] Unit tests: matching game — factory rounds, dedup, correct/wrong/alreadyMatched, isComplete (5 tests)
- [x] Unit tests: quiz engine — question count, 4 choices, correct answer in choices, score/streak, maxStreak, isFinished, no duplicates (7 tests)
- [x] All 18 tests pass: `flutter test`

---

## 🚀 Phase 10 — Submission Prep
- [ ] Deploy web build (Firebase Hosting, Vercel, or GitHub Pages)
- [ ] Live URL works and is publicly accessible
- [ ] GitHub repo is **public** with open-source license file
- [ ] `/.kiro` directory is in the repo (specs, steering, hooks)
- [ ] README.md written: what the app does, how to run it, screenshots
- [ ] Record demo video (≤ 3 minutes), uploaded to YouTube (public)
  - Show all 5 activities working
  - Show Halloween UI clearly
  - Narrate what problem it solves and who it's for
- [ ] Write Kiro usage write-up (for the Devpost submission form):
  - Which Kiro features used (spec-driven dev, steering, hooks, agents)
  - How spec-driven development differed from vibe coding
  - What steering docs changed about Kiro's responses
  - Any hooks automated

---

## 📝 Devpost Submission Checklist
- [ ] Submission form started (save drafts early!)
- [ ] Category selected: **Costume Contest**
- [ ] GitHub repo URL added
- [ ] Live app URL added
- [ ] Text description written
- [ ] Demo video URL added
- [ ] Kiro usage write-up filled in
- [ ] Bonus prizes selected (if applicable):
  - [ ] Best Demo (automatic)
  - [ ] Social Blitz Prize (post with #KiroweenHackathon26)
  - [ ] Bonus Blog Prize (write a blog post)
  - [ ] Best Ghost of Kiroween Past (if registered for 2025)
  - [ ] Best Student Project (if student)
- [ ] Submitted before **December 4, 2026 @ 10:00 PM UTC** ✅

---

## 📌 Resources
- [Kiro Documentation](https://kiro.dev/docs)
- [Kiroween Discord #kiroween-hackathon](https://discord.gg/kiro)
- [Hackathon Rules](https://kiroween2026.devpost.com/rules)
- [Flutter Docs](https://docs.flutter.dev)
- [How to add a GitHub license](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)
