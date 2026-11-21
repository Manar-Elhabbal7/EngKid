import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/services/audio_service.dart';
import '../../../shared/services/tts_service.dart';
import '../../../shared/providers/progress_provider.dart';
import '../../../shared/widgets/ghost_mascot.dart';
import '../../../shared/widgets/scaffold_with_background.dart';
import '../../../shared/widgets/star_reward.dart';
import '../../../shared/widgets/spooky_button.dart';
import '../models/matching_game.dart';
import '../widgets/emoji_tile.dart';
import '../widgets/word_slot.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen entry
// ─────────────────────────────────────────────────────────────────────────────

class MatchingScreen extends ConsumerStatefulWidget {
  const MatchingScreen({super.key});

  @override
  ConsumerState<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends ConsumerState<MatchingScreen> {
  late final List<MatchingRound> _rounds;
  late List<MatchPair> _shuffledWords; // word-slot order (shuffled)

  int _roundIndex = 0;
  bool _gameOver = false;

  /// id → wrong flag: cleared after 600 ms
  final Map<String, bool> _wrongEmoji = {};
  final Map<String, bool> _wrongWord = {};

  GhostExpression _expression = GhostExpression.happy;

  @override
  void initState() {
    super.initState();
    _rounds = MatchingGameFactory().buildRounds();
    _shuffleWordSlots();
  }

  MatchingRound get _round => _rounds[_roundIndex];

  void _shuffleWordSlots() {
    _shuffledWords = List.of(_round.pairs)..shuffle();
  }

  // ── Drag result handlers ─────────────────────────────────────────────────

  Future<void> _onCorrect(String id) async {
    _round.attempt(emojiId: id, wordId: id);
    await AudioService.instance.play(SfxType.chime);
    setState(() => _expression = GhostExpression.excited);
    await TtsService.instance.speak(_round.pairs.firstWhere((p) => p.id == id).word);

    if (_round.isComplete) {
      // Award a star per completed round.
      ref.read(totalStarsProvider.notifier).increment();
      await AudioService.instance.play(SfxType.sparkle);
    }
    if (mounted) setState(() => _expression = GhostExpression.happy);
  }

  Future<void> _onWrong(String emojiId, String wordId) async {
    _round.attempt(emojiId: emojiId, wordId: wordId); // logs wrong
    await AudioService.instance.play(SfxType.woo);
    setState(() {
      _wrongEmoji[emojiId] = true;
      _wrongWord[wordId] = true;
      _expression = GhostExpression.sad;
    });
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() {
        _wrongEmoji.remove(emojiId);
        _wrongWord.remove(wordId);
        _expression = GhostExpression.happy;
      });
    }
  }

  void _nextRound() {
    if (_roundIndex + 1 >= MatchingGameFactory.totalRounds) {
      setState(() => _gameOver = true);
    } else {
      setState(() {
        _roundIndex++;
        _shuffleWordSlots();
        _wrongEmoji.clear();
        _wrongWord.clear();
        _expression = GhostExpression.happy;
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_gameOver) return _GameOverScreen(onReplay: _replay, onHome: _goHome);

    return ScaffoldWithBackground(
      child: OrientationBuilder(
        builder: (context, orientation) => orientation == Orientation.portrait
            ? _buildPortrait()
            : _buildLandscape(),
      ),
    );
  }

  void _replay() => setState(() {
        _rounds.clear();
        _rounds.addAll(MatchingGameFactory().buildRounds());
        _roundIndex = 0;
        _gameOver = false;
        _shuffleWordSlots();
        _wrongEmoji.clear();
        _wrongWord.clear();
        _expression = GhostExpression.happy;
      });

  void _goHome() => context.go('/');

  // ── Portrait ──────────────────────────────────────────────────────────────

  Widget _buildPortrait() {
    return Column(
      children: [
        _TopBar(roundIndex: _roundIndex),
        const SizedBox(height: 8),
        GhostMascot(
          expression: _expression,
          size: 52,
          label: _expression == GhostExpression.excited
              ? 'Great match! 🎉'
              : _expression == GhostExpression.sad
                  ? 'Oops! Try again! 👻'
                  : 'Drag the emoji to its word!',
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _round.isComplete
              ? _RoundCompletePanel(
                  roundIndex: _roundIndex,
                  onNext: _nextRound,
                )
              : _buildMatchArea(portrait: true),
        ),
      ],
    );
  }

  // ── Landscape ─────────────────────────────────────────────────────────────

  Widget _buildLandscape() {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TopBar(roundIndex: _roundIndex, compact: true),
                const SizedBox(height: 12),
                GhostMascot(
                  expression: _expression,
                  size: 56,
                  label: _expression == GhostExpression.excited
                      ? '🎉'
                      : _expression == GhostExpression.sad
                          ? 'Try again!'
                          : 'Drag it!',
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _round.isComplete
              ? _RoundCompletePanel(roundIndex: _roundIndex, onNext: _nextRound)
              : _buildMatchArea(portrait: false),
        ),
      ],
    );
  }

  // ── Match area ─────────────────────────────────────────────────────────────

  Widget _buildMatchArea({required bool portrait}) {
    final pairs = _round.pairs;
    final matched = _round.matched;

    // Emoji column + Word column, side by side
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // ── Emoji tiles ──────────────────────────────────────────
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: pairs.map((pair) {
                return EmojiTile(
                  key: ValueKey('emoji_${pair.id}'),
                  pair: pair,
                  isMatched: matched.contains(pair.id),
                  isWrong: _wrongEmoji[pair.id] ?? false,
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 24),
          // ── Word slots ───────────────────────────────────────────
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _shuffledWords.map((pair) {
                return WordSlot(
                  key: ValueKey('word_${pair.id}'),
                  pair: pair,
                  isMatched: matched.contains(pair.id),
                  isWrong: _wrongWord[pair.id] ?? false,
                  onAccept: () => _onCorrect(pair.id),
                  onWrongDrop: () => _onWrong(pair.id, pair.id),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.roundIndex, this.compact = false});
  final int roundIndex;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: compact
          ? Column(
              children: [
                Text('🧩',
                    style: Theme.of(context).textTheme.headlineSmall),
                Text(
                  'Round ${roundIndex + 1}/${MatchingGameFactory.totalRounds}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: HalloweenColors.pumpkinYellow,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            )
          : Row(
              children: [
                Text(
                  '🧩 Word Matching',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HalloweenColors.pumpkinYellow,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                _RoundPips(current: roundIndex),
              ],
            ),
    );
  }
}

class _RoundPips extends StatelessWidget {
  const _RoundPips({required this.current});
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(MatchingGameFactory.totalRounds, (i) {
        final done = i < current;
        final active = i == current;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: active ? 20 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: done
                  ? HalloweenColors.spookyGreen
                  : active
                      ? HalloweenColors.pumpkinOrange
                      : HalloweenColors.ghostWhite.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        );
      }),
    );
  }
}

class _RoundCompletePanel extends StatelessWidget {
  const _RoundCompletePanel({
    required this.roundIndex,
    required this.onNext,
  });
  final int roundIndex;
  final VoidCallback onNext;

  bool get _isLast =>
      roundIndex + 1 >= MatchingGameFactory.totalRounds;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const StarReward(size: 72),
          const SizedBox(height: 16),
          Text(
            _isLast ? 'You finished all rounds! 🎉' : 'Round complete! ⭐',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: HalloweenColors.pumpkinYellow,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '+1 star earned!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: HalloweenColors.ghostWhite.withValues(alpha: 0.8),
                ),
          ),
          const SizedBox(height: 24),
          SpookyButton(
            label: _isLast ? 'See Results 🏆' : 'Next Round →',
            onPressed: onNext,
          ),
        ],
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .scaleXY(begin: 0.8, end: 1.0, duration: 500.ms, curve: Curves.elasticOut),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Game over / results screen
// ─────────────────────────────────────────────────────────────────────────────

class _GameOverScreen extends StatelessWidget {
  const _GameOverScreen({required this.onReplay, required this.onHome});
  final VoidCallback onReplay;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBackground(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GhostMascot(
                expression: GhostExpression.excited,
                size: 90,
                label: 'Amazing job! 🌟',
              ),
              const SizedBox(height: 20),
              Text(
                'You matched all the words!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: HalloweenColors.pumpkinYellow,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You earned ${MatchingGameFactory.totalRounds} stars! ⭐',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: HalloweenColors.ghostWhite
                          .withValues(alpha: 0.85),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SpookyButton(
                label: 'Play Again 🔄',
                onPressed: onReplay,
              ),
              const SizedBox(height: 16),
              SpookyButton(
                label: '🏚️ Go Home',
                onPressed: onHome,
                color: HalloweenColors.midPurple,
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.2, end: 0, duration: 500.ms),
        ),
      ),
    );
  }
}
