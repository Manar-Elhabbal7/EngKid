import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/activity_room.dart';
import '../../../app/theme.dart';

/// A tappable door card representing one activity room.
///
/// [isCompleted] draws a star badge in the top-right corner.
/// [index] staggers the entrance animation.
class RoomDoor extends StatelessWidget {
  const RoomDoor({
    super.key,
    required this.room,
    required this.onTap,
    required this.index,
    this.isCompleted = false,
  });

  final ActivityRoom room;
  final VoidCallback onTap;
  final int index;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: _DoorCard(
        room: room,
        isCompleted: isCompleted,
      )
          .animate()
          .fadeIn(
            duration: 500.ms,
            delay: Duration(milliseconds: 120 * index),
          )
          .slideY(
            begin: 0.3,
            end: 0,
            duration: 500.ms,
            delay: Duration(milliseconds: 120 * index),
            curve: Curves.easeOut,
          ),
    );
  }
}

class _DoorCard extends StatefulWidget {
  const _DoorCard({required this.room, required this.isCompleted});
  final ActivityRoom room;
  final bool isCompleted;

  @override
  State<_DoorCard> createState() => _DoorCardState();
}

class _DoorCardState extends State<_DoorCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hover;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _hover = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0,
      upperBound: 1,
    );
    _scale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hover, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _hover.forward(),
        onTapUp: (_) => _hover.reverse(),
        onTapCancel: () => _hover.reverse(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                room.color.withValues(alpha: 0.85),
                room.color.withValues(alpha: 0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: room.color,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: room.color.withValues(alpha: 0.4),
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // ── Door content ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      room.emoji,
                      style: const TextStyle(fontSize: 44),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      room.label,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: HalloweenColors.ghostWhite,
                                fontWeight: FontWeight.bold,
                              ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: HalloweenColors.ghostWhite
                                .withValues(alpha: 0.85),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // ── Completion star badge ─────────────────────────────
              if (widget.isCompleted)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: HalloweenColors.starGold,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              HalloweenColors.starGold.withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Text('⭐',
                        style: TextStyle(fontSize: 16)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
