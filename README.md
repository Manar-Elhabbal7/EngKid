# 🎃 EngKids: Learn English in a Haunted Forest

> **Kiroween 2026** · Category: **Costume Contest** · Built with **Kiro IDE**

EngKids teaches English to children aged 4–8. Boo, a friendly ghost, guides
them through five Halloween lessons, from hearing their first letters to
brewing a potion by listening for words. The spooky design does the teaching:
letters glow on pumpkins, words hide on forest cards, and ingredients splash
into a cauldron. Children who can't read yet can follow along by sound and
pictures alone.

**Live app:** _add Vercel URL_ · **🎬 Demo video:** _add YouTube URL_ ·
**Android APK:** [Releases](https://github.com/Manar-Elhabbal7/EngKid/releases)

---

## ✅ Hackathon eligibility

| Requirement | How EngKids meets it |
|---|---|
| New project built in the Submission Period (Oct 30 – Dec 4, 2026) | First commit **21 Nov 2026**; full history in this repo. |
| Working software built with Kiro | Built in **Kiro IDE**: see [How Kiro was used](#-how-kiro-was-used). |
| Public GitHub repo with all source, assets and instructions | Everything needed to run it is here; see [Run it](#-run-it). |
| Open-source license, visible in the About section | [MIT](LICENSE). |
| `/.kiro` directory at the repo root, not git-ignored | [`.kiro/specs`](.kiro/specs) and [`.kiro/steering`](.kiro/steering). |
| Working app URL | Live web app (link above). No login needed. |
| Demo video under 3 minutes, public on YouTube | Link above. |
| No third-party copyrighted material without permission | Every outside asset is listed with its source and license in [Credits](#-credits). |

---

## 🕯️ The five lessons

Each lesson opens once the one before it is finished.

| Lesson | What the child does |
|---|---|
| 🎃 **Alphabet Adventure** | Tap the glowing pumpkin to hear each letter, A to Z. |
| 👻 **Haunted Forest** | Flip a card to see and hear one of 20 forest words. |
| 🧩 **Word Matching** | Join each picture to its word; a glowing rope links each correct pair. |
| ❓ **Spell-It Quiz** | Tap letter pumpkins in order to spell a word; the right pumpkin glows after two misses. |
| 🧪 **Magic Cauldron** | Listen to Boo, then drop the right ingredient into the bubbling pot. |

**Also:** up to 2 child profiles, a Parent Dashboard (letters and words
learned, time played, skill bars), coins for every first success,
background music that pauses during lessons so children can focus, one-tap
mute, and a layout for portrait and landscape on Android, iOS and web.

---

## 🎨 Why it fits the Costume Contest

The Halloween theme drives every interaction:

- **Pumpkins are the letters.** One glowing pumpkin carries each letter in
  Alphabet Adventure, and small pumpkins are the letter tiles in Spell-It Quiz.
- **Mistakes are spooky, never harsh.** A wrong answer makes a soft ghostly
  "woo" and a shake. There is no red error colour, and Boo names the right
  answer so every mistake still teaches.
- **Rewards feel like magic.** Glowing ropes, rising coins, a cauldron that
  splashes and changes colour, and fireflies drifting over a moonlit graveyard.
- **Boo is always there.** He floats beside each lesson and tells the child,
  in a speech bubble, exactly what to do next.

---

## 🛠 How Kiro was used

The whole app was built in **Kiro IDE**.

- **Spec-driven development.** [`.kiro/specs/SPEC-engkids-v1.md`](.kiro/specs/SPEC-engkids-v1.md)
  was written before any code. It sets the audience, success criteria, tech
  stack and what was deferred, so each lesson was built against agreed goals
  instead of improvised.
- **Steering.** [`.kiro/steering/project.md`](.kiro/steering/project.md) holds
  the rules Kiro followed in every file: the Halloween palette, 48 dp minimum
  tap targets, a sound and haptic on every interaction, no red error colours
  for children, portrait and landscape layouts, and "always / ask first /
  never" boundaries.
- **Small, verified steps.** Each feature was built in slices, and none was
  marked done until `flutter analyze` was clean and every test passed.
- **Tests that caught real bugs.** The suite (112 tests) covers the rules of
  every lesson, saving progress, and the screens at phone sizes in both
  orientations. It caught a coin animation that drew a red error box, a crash
  when leaving a lesson, and a misnamed audio file (`pumbkin.mp3`) that would
  have played silently.

---

## 🚀 Run it

Requires [Flutter](https://docs.flutter.dev/get-started/install) 3.47.2 or newer.

```bash
git clone https://github.com/Manar-Elhabbal7/EngKid.git
cd EngKid
flutter pub get
flutter run -d chrome      # web
flutter run                # Android or iOS device
flutter test               # run the test suite
```

On web, browsers only allow sound after the first tap or click, so the
splash music starts once you interact with the page.

---

## 🙏 Credits

- **Letter voices** (`assets/audio/letters/A.mp3` … `Z.mp3`): recordings from
  [Show and Tell Letter](https://www.showandtellletter.com/letters).
- **Word voices** (`assets/audio/words/*.mp3`): pronunciations from
  [Forvo](https://forvo.com), recorded by Forvo community members, licensed
  [CC BY-NC-SA 3.0](https://creativecommons.org/licenses/by-nc-sa/3.0/)
  (credit required, non-commercial, share-alike). These files are not covered
  by this project's MIT license.
- **Theme music** (`assets/audio/halloween_splash.mp3`): _add source and license_.
- **Sound effects** (`chime`, `creak`, `sparkle`, `woo`): made for this project
  with Python and ffmpeg.
- **Font:** [Baloo 2](https://fonts.google.com/specimen/Baloo+2), SIL Open Font License.
- **Illustrations** (Boo, pumpkins, backgrounds, cauldron, padlock): _add source and license_.

## 📄 License

Code: [MIT](LICENSE). Third-party audio keeps the licenses listed in Credits.
