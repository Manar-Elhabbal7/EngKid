import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/scaffold_with_background.dart';
import '../../../shared/widgets/ghost_mascot.dart';
import '../models/vocab_data.dart';

/// Shows a grid of cauldron-style category tiles.
/// Tapping one calls [onCategorySelected].
class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({
    super.key,
    required this.onCategorySelected,
  });

  final void Function(VocabCategory) onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBackground(
      showBackButton: true,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                Text(
                  '👻 Haunted Forest',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: HalloweenColors.pumpkinYellow,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pick a cauldron to learn words!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: HalloweenColors.ghostWhite
                            .withValues(alpha: 0.75),
                      ),
                ),
                const SizedBox(height: 8),
                const GhostMascot(
                  expression: GhostExpression.thinking,
                  size: 54,
                  label: 'Which one will you choose? 🤔',
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: VocabData.categories.length,
              itemBuilder: (context, i) {
                final cat = VocabData.categories[i];
                return _CauldronTile(
                  category: cat,
                  index: i,
                  onTap: () => onCategorySelected(cat),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CauldronTile extends StatelessWidget {
  const _CauldronTile({
    required this.category,
    required this.index,
    required this.onTap,
  });

  final VocabCategory category;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              category.color.withValues(alpha: 0.85),
              category.color.withValues(alpha: 0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: category.color, width: 2),
          boxShadow: [
            BoxShadow(
              color: category.color.withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bubbling cauldron emoji
            Text('🫧', style: const TextStyle(fontSize: 20))
                .animate(
                  onPlay: (c) => c.repeat(reverse: true),
                  delay: Duration(milliseconds: 150 * index),
                )
                .moveY(begin: 0, end: -4, duration: 800.ms),
            Text(category.emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 6),
            Text(
              category.label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HalloweenColors.ghostWhite,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            Text(
              '${category.words.length} words',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HalloweenColors.ghostWhite
                        .withValues(alpha: 0.75),
                  ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(
            duration: 400.ms,
            delay: Duration(milliseconds: 60 * index),
          )
          .scaleXY(
            begin: 0.85,
            end: 1.0,
            duration: 400.ms,
            delay: Duration(milliseconds: 60 * index),
            curve: Curves.easeOut,
          ),
    );
  }
}
