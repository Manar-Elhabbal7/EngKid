import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../shared/providers/progress_provider.dart';
import '../../../shared/widgets/ghost_mascot.dart';
import '../../../shared/widgets/scaffold_with_background.dart';
import '../../../shared/widgets/star_reward.dart';
import '../widgets/bubbling_cauldron.dart';

/// Shows the child's overall progress across all activities.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitedLetters = ref.watch(visitedLettersProvider);
    final learnedWords   = ref.watch(learnedWordsProvider);
    final totalStars     = ref.watch(totalStarsProvider);

    final lettersPct = visitedLetters.length / 26;
    final wordsPct   = learnedWords.length / 50;

    return ScaffoldWithBackground(
      showBackButton: true,
      child: OrientationBuilder(
        builder: (context, orientation) => orientation == Orientation.portrait
            ? _buildPortrait(
                context,
                visitedLetters.length,
                learnedWords.length,
                totalStars,
                lettersPct,
                wordsPct,
              )
            : _buildLandscape(
                context,
                visitedLetters.length,
                learnedWords.length,
                totalStars,
                lettersPct,
                wordsPct,
              ),
      ),
    );
  }

  // ── Portrait ──────────────────────────────────────────────────────────────

  Widget _buildPortrait(
    BuildContext context,
    int letters,
    int words,
    int stars,
    double lettersPct,
    double wordsPct,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: [
          _Header(),
          const SizedBox(height: 20),
          _CauldronSection(
            letters: letters,
            words: words,
            stars: stars,
          ),
          const SizedBox(height: 28),
          _ProgressSection(
            letters: letters,
            words: words,
            lettersPct: lettersPct,
            wordsPct: wordsPct,
          ),
          const SizedBox(height: 28),
          _StarSection(stars: stars),
          const SizedBox(height: 24),
          _BooSection(letters: letters, words: words, stars: stars),
        ],
      ),
    );
  }

  // ── Landscape ─────────────────────────────────────────────────────────────

  Widget _buildLandscape(
    BuildContext context,
    int letters,
    int words,
    int stars,
    double lettersPct,
    double wordsPct,
  ) {
    return Row(
      children: [
        // Left — cauldron + Boo
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Header(compact: true),
                const SizedBox(height: 12),
                _CauldronSection(
                  letters: letters,
                  words: words,
                  stars: stars,
                  compact: true,
                ),
                const SizedBox(height: 12),
                _BooSection(
                    letters: letters, words: words, stars: stars, compact: true),
              ],
            ),
          ),
        ),
        // Right — progress bars + stars
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(8, 24, 24, 24),
            child: Column(
              children: [
                _ProgressSection(
                  letters: letters,
                  words: words,
                  lettersPct: lettersPct,
                  wordsPct: wordsPct,
                ),
                const SizedBox(height: 20),
                _StarSection(stars: stars),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '🫧 Magic Cauldron',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: HalloweenColors.pumpkinYellow,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: -0.2, end: 0, duration: 500.ms),
        if (!compact) ...[
          const SizedBox(height: 4),
          Text(
            'See how much you\'ve learned!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: HalloweenColors.ghostWhite.withValues(alpha: 0.75),
                ),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
        ],
      ],
    );
  }
}

class _CauldronSection extends StatelessWidget {
  const _CauldronSection({
    required this.letters,
    required this.words,
    required this.stars,
    this.compact = false,
  });
  final int letters;
  final int words;
  final int stars;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BubblingCauldron(size: compact ? 70 : 90),
        const SizedBox(height: 16),
        // Three stat bubbles
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatBubble(
              emoji: '🎃',
              value: '$letters',
              label: 'Letters',
              color: HalloweenColors.pumpkinOrange,
              delay: 0,
            ),
            _StatBubble(
              emoji: '👻',
              value: '$words',
              label: 'Words',
              color: const Color(0xFF7B2FBE),
              delay: 100,
            ),
            _StatBubble(
              emoji: '⭐',
              value: '$stars',
              label: 'Stars',
              color: HalloweenColors.starGold,
              delay: 200,
            ),
          ],
        ),
      ],
    );
  }
}

class _StatBubble extends StatelessWidget {
  const _StatBubble({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
    required this.delay,
  });
  final String emoji;
  final String value;
  final String label;
  final Color color;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: HalloweenColors.ghostWhite.withValues(alpha: 0.8),
                ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 300 + delay))
        .fadeIn(duration: 400.ms)
        .scaleXY(begin: 0.7, end: 1.0, duration: 500.ms, curve: Curves.elasticOut);
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({
    required this.letters,
    required this.words,
    required this.lettersPct,
    required this.wordsPct,
  });
  final int letters;
  final int words;
  final double lettersPct;
  final double wordsPct;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HalloweenColors.midPurple.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: HalloweenColors.pumpkinOrange.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Learning Journey',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: HalloweenColors.pumpkinYellow,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          HalloweenProgressBar(
            label: 'Letters',
            value: lettersPct,
            current: letters,
            total: 26,
            color: HalloweenColors.pumpkinOrange,
            emoji: '🎃',
          ),
          const SizedBox(height: 14),
          HalloweenProgressBar(
            label: 'Words',
            value: wordsPct,
            current: words,
            total: 50,
            color: const Color(0xFF7B2FBE),
            emoji: '👻',
          ),
        ],
      ),
    ).animate(delay: 400.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0, duration: 500.ms);
  }
}

class _StarSection extends StatelessWidget {
  const _StarSection({required this.stars});
  final int stars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HalloweenColors.starGold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: HalloweenColors.starGold.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          StarReward(size: stars > 0 ? 52 : 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stars > 0 ? 'You\'ve earned $stars stars!' : 'No stars yet!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HalloweenColors.starGold,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  stars > 0
                      ? 'Keep exploring to earn more! ⭐'
                      : 'Start learning to earn your first star! 🎃',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: HalloweenColors.ghostWhite.withValues(alpha: 0.75),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: 600.ms).fadeIn(duration: 500.ms);
  }
}

class _BooSection extends StatelessWidget {
  const _BooSection({
    required this.letters,
    required this.words,
    required this.stars,
    this.compact = false,
  });
  final int letters;
  final int words;
  final int stars;
  final bool compact;

  String get _message {
    if (letters == 26 && words >= 40) return 'You know everything! 🏆';
    if (stars >= 20) return 'You\'re a spelling wizard! 🧙';
    if (letters >= 13) return 'Halfway through the alphabet! 🎃';
    if (words >= 10) return 'Great vocabulary so far! 👻';
    if (stars > 0) return 'You\'re doing great! Keep going! ⭐';
    return 'Let\'s start learning! Tap a room! 🏚️';
  }

  @override
  Widget build(BuildContext context) {
    return GhostMascot(
      expression: stars > 10 ? GhostExpression.excited : GhostExpression.happy,
      size: compact ? 54 : 70,
      label: _message,
    ).animate(delay: 800.ms).fadeIn(duration: 500.ms);
  }
}
