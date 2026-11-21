import 'package:flutter/material.dart';
import '../../../app/router.dart';

/// One activity room inside the haunted mansion.
class ActivityRoom {
  const ActivityRoom({
    required this.id,
    required this.emoji,
    required this.label,
    required this.route,
    required this.color,
    required this.description,
  });

  /// Unique stable id used for Hive progress tracking.
  final String id;
  final String emoji;
  final String label;
  final String route;
  final Color color;
  final String description;
}

/// The five rooms, in the order they appear on the mansion map.
const List<ActivityRoom> kActivityRooms = [
  ActivityRoom(
    id: 'alphabet',
    emoji: '🎃',
    label: 'Alphabet Adventure',
    route: AppRoutes.alphabet,
    color: Color(0xFFFF6B00),
    description: 'Learn A to Z!',
  ),
  ActivityRoom(
    id: 'vocab',
    emoji: '👻',
    label: 'Haunted Forest',
    route: AppRoutes.vocab,
    color: Color(0xFF7B2FBE),
    description: 'Learn new words!',
  ),
  ActivityRoom(
    id: 'matching',
    emoji: '🧩',
    label: 'Word Matching',
    route: AppRoutes.matching,
    color: Color(0xFF0077B6),
    description: 'Match the picture!',
  ),
  ActivityRoom(
    id: 'quiz',
    emoji: '❓',
    label: 'Spell-It Quiz',
    route: AppRoutes.quiz,
    color: Color(0xFF2DC653),
    description: 'Spell the word!',
  ),
  ActivityRoom(
    id: 'progress',
    emoji: '🫧',
    label: 'Magic Cauldron',
    route: AppRoutes.progress,
    color: Color(0xFFFFD700),
    description: 'See your stars!',
  ),
];
