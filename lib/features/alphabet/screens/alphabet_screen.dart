import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../shared/services/audio_service.dart';
import '../../../shared/services/tts_service.dart';
import '../../../shared/providers/progress_provider.dart';
import '../../../shared/widgets/ghost_mascot.dart';
import '../../../shared/widgets/scaffold_with_background.dart';
import '../../../shared/widgets/star_reward.dart';
import '../models/letter_data.dart';
import '../widgets/pumpkin_letter_card.dart';

/// Alphabet Adventure screen.
///
/// A [PageView] of 26 pumpkin letter cards. Tapping a card speaks the letter
/// and example word via TTS and awards a star on the first visit.
class AlphabetScreen extends ConsumerStatefulWidget {
  const AlphabetScreen({super.key});

  @override
  ConsumerState<AlphabetScreen> createState() => _AlphabetScreenState();
}

class _AlphabetScreenState extends ConsumerState<AlphabetScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  /// Shown briefly after a new letter is visited.
  bool _showStar = false;

  /// Current expression for Boo.
  GhostExpression _expression = GhostExpression.happy;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Speak the first letter after first frame.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _speakCurrent(awardStar: false));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _speakCurrent({bool awardStar = true}) async {
    final entry = kAlphabet[_currentIndex];
    final visited = ref.read(visitedLettersProvider);
    final isNew = !visited.contains(entry.letter);

    // Animate Boo to excited before speaking.
    setState(() => _expression = GhostExpression.excited);

    await TtsService.instance.speak(entry.ttsPhrase);

    if (awardStar && isNew) {
      ref.read(visitedLettersProvider.notifier).add(entry.letter);
      ref.read(totalStarsProvider.notifier).increment();
      await AudioService.instance.play(SfxType.sparkle);
      setState(() => _showStar = true);
      await Future<void>.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _showStar = false);
    }

    if (mounted) setState(() => _expression = GhostExpression.happy);
  }

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final visitedLetters = ref.watch(visitedLettersProvider);
    final totalStars = ref.watch(totalStarsProvider);
    final visitedCount = visitedLetters.length;

    return ScaffoldWithBackground(
      showBackButton: true,
      child: OrientationBuilder(
        builder: (context, orientation) {
          return orientation == Orientation.portrait
              ? _buildPortrait(visitedLetters, visitedCount, totalStars)
              : _buildLandscape(visitedLetters, visitedCount, totalStars);
        },
      ),
    );
  }

  // ── Portrait ─────────────────────────────────────────────────────────────

  Widget _buildPortrait(
      Set<String> visited, int visitedCount, int totalStars) {
    return Stack(
      children: [
        Column(
          children: [
            _TopBar(visitedCount: visitedCount, totalStars: totalStars),
            Expanded(child: _buildCardPageView(visited: visited)),
            _ProgressDots(current: _currentIndex),
            const SizedBox(height: 8),
            _NavRow(
              currentIndex: _currentIndex,
              onPrev: _currentIndex > 0
                  ? () => _goTo(_currentIndex - 1)
                  : null,
              onNext: _currentIndex < 25
                  ? () => _goTo(_currentIndex + 1)
                  : null,
            ),
            const SizedBox(height: 12),
            _BooRow(expression: _expression),
            const SizedBox(height: 16),
          ],
        ),
        if (_showStar) _StarOverlay(),
      ],
    );
  }

  // ── Landscape ────────────────────────────────────────────────────────────

  Widget _buildLandscape(
      Set<String> visited, int visitedCount, int totalStars) {
    return Stack(
      children: [
        Row(
          children: [
            // Left: Boo + progress
            SizedBox(
              width: 160,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GhostMascot(expression: _expression, size: 64),
                    const SizedBox(height: 12),
                    _StarsChip(totalStars: totalStars),
                    const SizedBox(height: 8),
                    Text(
                      '$visitedCount / 26',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: HalloweenColors.ghostWhite
                                .withValues(alpha: 0.8),
                          ),
                    ),
                    Text(
                      'letters',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: HalloweenColors.ghostWhite
                                .withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
            ),
            // Right: card + nav
            Expanded(
              child: Column(
                children: [
                  Expanded(child: _buildCardPageView(visited: visited)),
                  _NavRow(
                    currentIndex: _currentIndex,
                    onPrev: _currentIndex > 0
                        ? () => _goTo(_currentIndex - 1)
                        : null,
                    onNext: _currentIndex < 25
                        ? () => _goTo(_currentIndex + 1)
                        : null,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
        if (_showStar) _StarOverlay(),
      ],
    );
  }

  // ── PageView helper ───────────────────────────────────────────────────────

  Widget _buildCardPageView({required Set<String> visited}) {
    return PageView.builder(
      controller: _pageController,
      itemCount: kAlphabet.length,
      onPageChanged: (i) {
        setState(() => _currentIndex = i);
        _speakCurrent();
      },
      itemBuilder: (context, i) {
        return PumpkinLetterCard(
          key: ValueKey(kAlphabet[i].letter),
          entry: kAlphabet[i],
          isVisited: visited.contains(kAlphabet[i].letter),
          onTap: _speakCurrent,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.visitedCount, required this.totalStars});
  final int visitedCount;
  final int totalStars;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Text(
            '🎃 Alphabet Adventure',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: HalloweenColors.pumpkinYellow,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          _StarsChip(totalStars: totalStars),
          const SizedBox(width: 10),
          _VisitedChip(visitedCount: visitedCount),
        ],
      ),
    );
  }
}

class _StarsChip extends StatelessWidget {
  const _StarsChip({required this.totalStars});
  final int totalStars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: HalloweenColors.starGold.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HalloweenColors.starGold, width: 1.5),
      ),
      child: Text(
        '⭐ $totalStars',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: HalloweenColors.starGold,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _VisitedChip extends StatelessWidget {
  const _VisitedChip({required this.visitedCount});
  final int visitedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: HalloweenColors.pumpkinOrange.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: HalloweenColors.pumpkinOrange, width: 1.5),
      ),
      child: Text(
        '$visitedCount / 26',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: HalloweenColors.pumpkinOrange,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.current});
  final int current;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 26,
        separatorBuilder: (context, i) => const SizedBox(width: 3),
        itemBuilder: (_, i) {
          final isActive = i == current;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 16 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive
                  ? HalloweenColors.pumpkinOrange
                  : HalloweenColors.ghostWhite.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        },
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.currentIndex,
    required this.onPrev,
    required this.onNext,
  });
  final int currentIndex;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavButton(
            icon: Icons.arrow_back_ios_rounded,
            onTap: onPrev,
            label: currentIndex > 0
                ? kAlphabet[currentIndex - 1].letter
                : '',
          ),
          Text(
            '${currentIndex + 1} / 26',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: HalloweenColors.ghostWhite.withValues(alpha: 0.7),
                ),
          ),
          _NavButton(
            icon: Icons.arrow_forward_ios_rounded,
            onTap: onNext,
            label: currentIndex < 25
                ? kAlphabet[currentIndex + 1].letter
                : '',
            labelOnLeft: false,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.label,
    this.labelOnLeft = true,
  });
  final IconData icon;
  final VoidCallback? onTap;
  final String label;
  final bool labelOnLeft;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final children = [
      if (labelOnLeft && label.isNotEmpty)
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: enabled
                    ? HalloweenColors.pumpkinOrange
                    : Colors.transparent,
                fontWeight: FontWeight.bold,
              ),
        ),
      IconButton(
        onPressed: onTap,
        icon: Icon(icon),
        color: enabled
            ? HalloweenColors.pumpkinOrange
            : HalloweenColors.ghostWhite.withValues(alpha: 0.2),
        iconSize: 32,
      ),
      if (!labelOnLeft && label.isNotEmpty)
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: enabled
                    ? HalloweenColors.pumpkinOrange
                    : Colors.transparent,
                fontWeight: FontWeight.bold,
              ),
        ),
    ];
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}

class _BooRow extends StatelessWidget {
  const _BooRow({required this.expression});
  final GhostExpression expression;

  @override
  Widget build(BuildContext context) {
    return GhostMascot(
      expression: expression,
      size: 56,
      label: expression == GhostExpression.excited
          ? 'Great! Listen carefully! 👂'
          : 'Tap the pumpkin to hear me! 🎃',
    );
  }
}

class _StarOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const StarReward(size: 80),
              const SizedBox(height: 12),
              Text(
                'New letter! +1 ⭐',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: HalloweenColors.starGold,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color:
                              HalloweenColors.pumpkinOrange.withValues(alpha: 0.7),
                          blurRadius: 12,
                        ),
                      ],
                    ),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .scaleXY(begin: 0.7, end: 1.0, duration: 400.ms, curve: Curves.elasticOut),
        ),
      ),
    );
  }
}
