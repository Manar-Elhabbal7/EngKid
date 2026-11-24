import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:engkids/features/lessons/models/lesson.dart';
import 'package:engkids/features/profiles/providers/profiles_provider.dart';
import 'package:engkids/features/progress/models/child_progress.dart';
import 'package:engkids/features/progress/providers/progress_provider.dart';
import 'package:engkids/shared/audio/audio_service.dart';
import 'package:engkids/shared/audio/letter_voice.dart';
import 'package:engkids/shared/widgets/lesson_finished_dialog.dart';

/// What every listening lesson shares: background music paused for focus,
/// time played tracked, the voice stopped on mute or when the app is left,
/// and coins given only after a full first listen.
mixin LessonSession<T extends ConsumerStatefulWidget>
    on ConsumerState<T>, WidgetsBindingObserver {
  // Captured once in initState: `ref` can't be used while the screen closes.
  late final String profileId;
  late final ProgressNotifier progress;
  late final LetterVoice voice;
  late final AudioService audio;
  final _clock = Stopwatch()..start();

  var speaking = false;
  var mutedHint = false;
  var burstId = 0;
  var burstCoins = 0;

  ChildProgress get myProgress => progress.of(profileId);

  @override
  void initState() {
    super.initState();
    profileId = ref.read(currentProfileProvider).id;
    progress = ref.read(progressProvider.notifier);
    voice = ref.read(letterVoiceProvider);
    audio = ref.read(audioServiceProvider);
    WidgetsBinding.instance.addObserver(this);
    // Focus time: no background music while learning, even when the app
    // isn't muted. It comes back when the child leaves.
    audio.pauseTheme();
    // Muting while something plays stops it (and it won't count as heard).
    ref.listenManual(audioServiceProvider.select((a) => a.muted), (_, muted) {
      if (muted) voice.stop();
      if (!muted && mounted) setState(() => mutedHint = false);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _clock.start();
    } else {
      saveTime();
      _clock.stop();
      voice.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    voice.stop();
    audio.resumeTheme();
    // Save after this frame: changing progress while the screen is being
    // removed would try to rebuild it.
    final played = _clock.elapsed;
    final notifier = progress;
    final id = profileId;
    Future.microtask(() => notifier.addPlayTime(id, played));
    super.dispose();
  }

  void saveTime() {
    final played = _clock.elapsed;
    _clock.reset();
    progress.addPlayTime(profileId, played);
  }

  /// Plays something with [play]. Only if it finished, [reward] runs and
  /// returns the coins it gave (0 when already heard before).
  Future<void> listen({
    required Future<bool> Function(LetterVoice voice) play,
    required Future<int> Function() reward,
  }) async {
    if (speaking) return;
    if (audio.muted) {
      setState(() => mutedHint = true);
      return;
    }
    setState(() => speaking = true);
    final heard = await play(voice);
    if (!mounted) return;
    setState(() => speaking = false);
    if (!heard) return;
    final earned = await reward();
    if (earned == 0) return;
    audio.playSfx('audio/chime.mp3');
    if (mounted) {
      setState(() {
        burstCoins = earned;
        burstId++;
      });
    }
  }

  /// Applies a progress change that may give coins; returns the coins.
  Future<int> earn((ChildProgress, int) Function(ChildProgress p) rule) async {
    final (_, coins) = rule(myProgress);
    if (coins > 0) await progress.update(profileId, (p) => rule(p).$1);
    return coins;
  }

  /// Ends the lesson: bonus coins (once), the finish box, back to games.
  Future<void> finishLesson({
    required Lesson lesson,
    required String message,
    required (ChildProgress, int) Function(ChildProgress p) rule,
  }) async {
    voice.stop();
    final bonus = await earn(rule);
    audio.playSfx('audio/sparkle.mp3');
    saveTime();
    if (!mounted) return;
    await LessonFinishedDialog.show(
      context,
      lesson: lesson,
      message: message,
      bonus: bonus,
    );
    if (mounted) context.go('/play');
  }

  /// Moves on within the lesson (stops any sound, plays the sparkle).
  void stepForward(VoidCallback change) {
    voice.stop();
    audio.playSfx('audio/sparkle.mp3');
    setState(() {
      change();
      speaking = false;
    });
  }
}
