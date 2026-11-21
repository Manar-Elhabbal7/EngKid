import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/ghost_mascot.dart';
import '../../../shared/widgets/scaffold_with_background.dart';
import '../../../shared/services/tts_service.dart';
import '../../../shared/services/audio_service.dart';
import '../models/activity_room.dart';
import '../widgets/room_door.dart';

/// The haunted mansion home screen.
///
/// Layout adapts to orientation:
///  - Portrait  → 2-column grid of doors + header above
///  - Landscape → Boo mascot on the left, door grid on the right
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _greeted = false;

  @override
  void initState() {
    super.initState();
    // Delay so the first frame paints before TTS fires.
    WidgetsBinding.instance.addPostFrameCallback((_) => _greet());
  }

  Future<void> _greet() async {
    if (_greeted) return;
    _greeted = true;
    await AudioService.instance.play(SfxType.creak);
    await TtsService.instance.speak("Hi! I'm Boo! Let's learn English!");
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBackground(
      child: OrientationBuilder(
        builder: (context, orientation) {
          return orientation == Orientation.portrait
              ? _PortraitLayout(onRoomTap: _navigateTo)
              : _LandscapeLayout(onRoomTap: _navigateTo);
        },
      ),
    );
  }

  void _navigateTo(ActivityRoom room) {
    AudioService.instance.play(SfxType.creak);
    context.go(room.route);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Portrait layout
// ─────────────────────────────────────────────────────────────────────────────

class _PortraitLayout extends StatelessWidget {
  const _PortraitLayout({required this.onRoomTap});
  final void Function(ActivityRoom) onRoomTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        children: [
          _MansionHeader(),
          const SizedBox(height: 24),
          _BooGreeting(),
          const SizedBox(height: 28),
          _DoorsGrid(onRoomTap: onRoomTap),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Landscape layout
// ─────────────────────────────────────────────────────────────────────────────

class _LandscapeLayout extends StatelessWidget {
  const _LandscapeLayout({required this.onRoomTap});
  final void Function(ActivityRoom) onRoomTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left column — title + Boo
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MansionHeader(),
                const SizedBox(height: 20),
                _BooGreeting(),
              ],
            ),
          ),
        ),
        // Right column — activity doors
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(8, 16, 20, 16),
            child: _DoorsGrid(onRoomTap: onRoomTap),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _MansionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '🏚️',
          style: const TextStyle(fontSize: 56),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .scaleXY(begin: 0.7, end: 1.0, duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: 8),
        Text(
          'Haunted Mansion',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: HalloweenColors.pumpkinYellow,
                shadows: [
                  Shadow(
                    color: HalloweenColors.pumpkinOrange.withValues(alpha: 0.7),
                    blurRadius: 12,
                  ),
                ],
              ),
          textAlign: TextAlign.center,
        )
            .animate(delay: 200.ms)
            .fadeIn(duration: 500.ms)
            .slideY(begin: -0.2, end: 0, duration: 500.ms),
        const SizedBox(height: 4),
        Text(
          'Pick a room to start learning!',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: HalloweenColors.ghostWhite.withValues(alpha: 0.8),
              ),
          textAlign: TextAlign.center,
        ).animate(delay: 350.ms).fadeIn(duration: 400.ms),
      ],
    );
  }
}

class _BooGreeting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const GhostMascot(
      expression: GhostExpression.waving,
      size: 80,
      label: "Hi! I'm Boo! 👋",
    );
  }
}

class _DoorsGrid extends StatelessWidget {
  const _DoorsGrid({required this.onRoomTap});
  final void Function(ActivityRoom) onRoomTap;

  @override
  Widget build(BuildContext context) {
    // 5 rooms: 2 columns, last row centered.
    return Column(
      children: [
        // Row 1: rooms 0, 1
        Row(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 0.9,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: RoomDoor(
                    room: kActivityRooms[0],
                    index: 0,
                    onTap: () => onRoomTap(kActivityRooms[0]),
                  ),
                ),
              ),
            ),
            Expanded(
              child: AspectRatio(
                aspectRatio: 0.9,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: RoomDoor(
                    room: kActivityRooms[1],
                    index: 1,
                    onTap: () => onRoomTap(kActivityRooms[1]),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Row 2: rooms 2, 3
        Row(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 0.9,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: RoomDoor(
                    room: kActivityRooms[2],
                    index: 2,
                    onTap: () => onRoomTap(kActivityRooms[2]),
                  ),
                ),
              ),
            ),
            Expanded(
              child: AspectRatio(
                aspectRatio: 0.9,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: RoomDoor(
                    room: kActivityRooms[3],
                    index: 3,
                    onTap: () => onRoomTap(kActivityRooms[3]),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Row 3: room 4 centered
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.42,
              child: AspectRatio(
                aspectRatio: 0.9,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: RoomDoor(
                    room: kActivityRooms[4],
                    index: 4,
                    onTap: () => onRoomTap(kActivityRooms[4]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
