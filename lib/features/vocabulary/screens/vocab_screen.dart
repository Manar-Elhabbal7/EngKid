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
import '../models/vocab_data.dart';
import '../widgets/vocab_flip_card.dart';
import 'category_screen.dart';

/// Entry point for the Vocabulary Haunted Forest.
///
/// Shows [CategorySelectionScreen] first, then the word PageView
/// for the chosen category.
class VocabScreen extends StatefulWidget {
  const VocabScreen({super.key});

  @override
  State<VocabScreen> createState() => _VocabScreenState();
}

class _VocabScreenState extends State<VocabScreen> {
  VocabCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    if (_selectedCategory == null) {
      return CategorySelectionScreen(
        onCategorySelected: (cat) =>
            setState(() => _selectedCategory = cat),
      );
    }
    return _WordCardsScreen(
      category: _selectedCategory!,
      onBack: () => setState(() => _selectedCategory = null),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Word cards screen
// ─────────────────────────────────────────────────────────────────────────────

class _WordCardsScreen extends ConsumerStatefulWidget {
  const _WordCardsScreen({
    required this.category,
    required this.onBack,
  });

  final VocabCategory category;
  final VoidCallback onBack;

  @override
  ConsumerState<_WordCardsScreen> createState() => _WordCardsScreenState();
}

class _WordCardsScreenState extends ConsumerState<_WordCardsScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _showStar = false;
  GhostExpression _expression = GhostExpression.happy;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  VocabWord get _currentWord => widget.category.words[_currentIndex];

  Future<void> _handleCardTap() async {
    if (!_isFlipped) {
      // Flip to back and speak.
      setState(() {
        _isFlipped = true;
        _expression = GhostExpression.excited;
      });
      await TtsService.instance.speak(_currentWord.ttsPhrase);

      // Award star if first time learning this word.
      final learned = ref.read(learnedWordsProvider);
      if (!learned.contains(_currentWord.word)) {
        ref.read(learnedWordsProvider.notifier).add(_currentWord.word);
        ref.read(totalStarsProvider.notifier).increment();
        await AudioService.instance.play(SfxType.sparkle);
        if (mounted) setState(() => _showStar = true);
        await Future<void>.delayed(const Duration(seconds: 2));
        if (mounted) setState(() => _showStar = false);
      }
      if (mounted) setState(() => _expression = GhostExpression.happy);
    } else {
      // Already flipped — tap again to hear the word again.
      setState(() => _expression = GhostExpression.excited);
      await TtsService.instance.speak(_currentWord.ttsPhrase);
      if (mounted) setState(() => _expression = GhostExpression.happy);
    }
  }

  void _goTo(int index) {
    setState(() {
      _currentIndex = index;
      _isFlipped = false;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final learned = ref.watch(learnedWordsProvider);
    final totalStars = ref.watch(totalStarsProvider);
    final learnedInCat = widget.category.words
        .where((w) => learned.contains(w.word))
        .length;

    return ScaffoldWithBackground(
      child: Stack(
        children: [
          OrientationBuilder(
            builder: (context, orientation) =>
                orientation == Orientation.portrait
                    ? _buildPortrait(learned, learnedInCat, totalStars)
                    : _buildLandscape(learned, learnedInCat, totalStars),
          ),
          if (_showStar) _StarOverlay(),
        ],
      ),
    );
  }

  // ── Portrait ──────────────────────────────────────────────────────────────

  Widget _buildPortrait(Set<String> learned, int learnedInCat, int totalStars) {
    return Column(
      children: [
        _TopBar(
          category: widget.category,
          learnedInCat: learnedInCat,
          totalStars: totalStars,
          onBack: widget.onBack,
        ),
        Expanded(child: _buildPageView(learned)),
        _NavRow(
          currentIndex: _currentIndex,
          total: widget.category.words.length,
          onPrev: _currentIndex > 0 ? () => _goTo(_currentIndex - 1) : null,
          onNext: _currentIndex < widget.category.words.length - 1
              ? () => _goTo(_currentIndex + 1)
              : null,
        ),
        const SizedBox(height: 8),
        GhostMascot(
          expression: _expression,
          size: 52,
          label: _isFlipped
              ? 'Now you know this word! 🌟'
              : 'Tap the card to reveal! 🎃',
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Landscape ─────────────────────────────────────────────────────────────

  Widget _buildLandscape(
      Set<String> learned, int learnedInCat, int totalStars) {
    return Row(
      children: [
        SizedBox(
          width: 160,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GhostMascot(expression: _expression, size: 56),
                const SizedBox(height: 8),
                Text(
                  '$learnedInCat / ${widget.category.words.length}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HalloweenColors.pumpkinYellow,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'learned',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            HalloweenColors.ghostWhite.withValues(alpha: 0.7),
                      ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                  label: const Text('Categories'),
                  style: TextButton.styleFrom(
                    foregroundColor: HalloweenColors.pumpkinOrange,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(child: _buildPageView(learned)),
              _NavRow(
                currentIndex: _currentIndex,
                total: widget.category.words.length,
                onPrev:
                    _currentIndex > 0 ? () => _goTo(_currentIndex - 1) : null,
                onNext: _currentIndex < widget.category.words.length - 1
                    ? () => _goTo(_currentIndex + 1)
                    : null,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPageView(Set<String> learned) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.category.words.length,
      onPageChanged: (i) => setState(() {
        _currentIndex = i;
        _isFlipped = false;
      }),
      itemBuilder: (context, i) {
        final word = widget.category.words[i];
        return Center(
          child: VocabFlipCard(
            key: ValueKey('${widget.category.id}_$i'),
            word: word,
            categoryColor: widget.category.color,
            isFlipped: i == _currentIndex && _isFlipped,
            isLearned: learned.contains(word.word),
            onTap: i == _currentIndex ? _handleCardTap : () {},
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.category,
    required this.learnedInCat,
    required this.totalStars,
    required this.onBack,
  });
  final VocabCategory category;
  final int learnedInCat;
  final int totalStars;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: HalloweenColors.pumpkinOrange,
          ),
          Text(
            '${category.emoji} ${category.label}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: HalloweenColors.pumpkinYellow,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          _Chip(
            label: '$learnedInCat/${category.words.length}',
            color: category.color,
          ),
          const SizedBox(width: 8),
          _Chip(label: '⭐ $totalStars', color: HalloweenColors.starGold),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.currentIndex,
    required this.total,
    required this.onPrev,
    required this.onNext,
  });
  final int currentIndex;
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: onPrev != null
                ? HalloweenColors.pumpkinOrange
                : HalloweenColors.ghostWhite.withValues(alpha: 0.2),
            iconSize: 28,
          ),
          Text(
            '${currentIndex + 1} / $total',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: HalloweenColors.ghostWhite.withValues(alpha: 0.7),
                ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            color: onNext != null
                ? HalloweenColors.pumpkinOrange
                : HalloweenColors.ghostWhite.withValues(alpha: 0.2),
            iconSize: 28,
          ),
        ],
      ),
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
              const StarReward(size: 72),
              const SizedBox(height: 10),
              Text(
                'New word! +1 ⭐',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: HalloweenColors.starGold,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .scaleXY(
                begin: 0.7,
                end: 1.0,
                duration: 400.ms,
                curve: Curves.elasticOut,
              ),
        ),
      ),
    );
  }
}
