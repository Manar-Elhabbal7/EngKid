import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:engkids/app/theme.dart';
import 'package:engkids/features/alphabet/models/alphabet.dart';
import 'package:engkids/features/alphabet/models/alphabet_progress.dart';
import 'package:engkids/features/alphabet/widgets/alphabet_finished_dialog.dart';
import 'package:engkids/features/alphabet/widgets/alphabet_header.dart';
import 'package:engkids/features/alphabet/widgets/alphabet_stage.dart';
import 'package:engkids/features/profiles/providers/profiles_provider.dart';
import 'package:engkids/features/progress/models/child_progress.dart';
import 'package:engkids/features/progress/providers/progress_provider.dart';
import 'package:engkids/shared/audio/audio_service.dart';
import 'package:engkids/shared/audio/letter_voice.dart';

/// Alphabet Adventure: tap the pumpkin to hear each letter A–Z.
/// The first full listen of a letter gives coins; after Z the lesson is
/// finished, which opens Haunted Forest.
class AlphabetScreen extends ConsumerStatefulWidget {
  const AlphabetScreen({super.key});

  @override
  ConsumerState<AlphabetScreen> createState() => _AlphabetScreenState();
}

class _AlphabetScreenState extends ConsumerState<AlphabetScreen>
    with WidgetsBindingObserver {
  late final String _profileId = ref.read(currentProfileProvider).id;
  late final ProgressNotifier _progress = ref.read(progressProvider.notifier);
  late final LetterVoice _voice = ref.read(letterVoiceProvider);
  late int _index = _progress.of(_profileId).alphabetResumeIndex;
  final _clock = Stopwatch()..start();

  var _speaking = false;
  var _mutedHint = false;
  var _burstId = 0;
  var _burstCoins = 0;

  AlphabetLetter get _letter => Alphabet.letters[_index];
  bool get _isLast => _index == Alphabet.letters.length - 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Muting while a letter plays stops it (and it won't count as heard).
    ref.listenManual(audioServiceProvider.select((a) => a.muted), (_, muted) {
      if (muted) _voice.stop();
      if (!muted && mounted) setState(() => _mutedHint = false);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _clock.start();
    } else {
      _saveTime();
      _clock.stop();
      _voice.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveTime();
    _voice.stop();
    super.dispose();
  }

  void _saveTime() {
    final played = _clock.elapsed;
    _clock.reset();
    _progress.addPlayTime(_profileId, played);
  }

  Future<void> _hear() async {
    if (_speaking) return;
    final audio = ref.read(audioServiceProvider);
    if (audio.muted) {
      setState(() => _mutedHint = true);
      return;
    }
    final letter = _letter;
    setState(() => _speaking = true);
    final heard = await _voice.say(letter);
    if (!mounted) return;
    setState(() => _speaking = false);
    if (!heard) return;

    // Coins only the first time this child hears the letter.
    final (_, earned) = _progress.of(_profileId).withLetterHeard(letter);
    if (earned == 0) return;
    await _progress.update(_profileId, (p) => p.withLetterHeard(letter).$1);
    audio.playSfx('audio/chime.mp3');
    if (mounted) {
      setState(() {
        _burstCoins = earned;
        _burstId++;
      });
    }
  }

  Future<void> _next() async {
    _voice.stop();
    final audio = ref.read(audioServiceProvider);
    if (!_isLast) {
      audio.playSfx('audio/sparkle.mp3');
      setState(() {
        _index++;
        _speaking = false;
      });
      return;
    }
    final (_, bonus) = _progress.of(_profileId).withAlphabetFinished();
    if (bonus > 0) {
      await _progress.update(_profileId, (p) => p.withAlphabetFinished().$1);
    }
    audio.playSfx('audio/sparkle.mp3');
    _saveTime();
    if (!mounted) return;
    await AlphabetFinishedDialog.show(context, bonus);
    if (mounted) context.go('/play');
  }

  String _bubble(ChildProgress p) {
    if (_mutedHint) return 'Turn on the sound to hear me!';
    if (_speaking) return 'Listen carefully!';
    if (!p.hasHeard(_letter)) return 'Tap the pumpkin to hear the letter!';
    return _isLast ? 'You did it! Tap Finish!' : 'Great job! Tap Next!';
  }

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(progressProvider)[_profileId] ?? ChildProgress.empty;
    return Scaffold(
      backgroundColor: HalloweenColors.nightSky,
      body: LayoutBuilder(
        builder: (context, screen) {
          final wide = screen.maxWidth > screen.maxHeight;
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                wide
                    ? 'assets/images/background_alpha.png'
                    : 'assets/images/alphabet_bg.jpg',
                fit: BoxFit.cover,
                cacheWidth: 1600,
                excludeFromSemantics: true,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x99100318), Colors.transparent],
                    stops: [0, 0.3],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Column(
                    children: [
                      AlphabetHeader(
                        coins: p.coins,
                        onBack: () => context.go('/play'),
                      ),
                      Expanded(
                        child: AlphabetStage(
                          wide: wide,
                          letter: _letter,
                          number: _index + 1,
                          bubble: _bubble(p),
                          speaking: _speaking,
                          heard: p.hasHeard(_letter),
                          isLast: _isLast,
                          burstId: _burstId,
                          burstCoins: _burstCoins,
                          onPumpkinTap: _hear,
                          onNext: _next,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
