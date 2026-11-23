import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:engkids/app/theme.dart';
import 'package:engkids/shared/audio/audio_service.dart';

class MuteButton extends ConsumerWidget {
  const MuteButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muted = ref.watch(audioServiceProvider).muted;
    return Tooltip(
      message: muted ? 'Unmute music' : 'Mute music',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            ref.read(audioServiceProvider).toggleMute();
          },
          customBorder: const CircleBorder(),
          child: Ink(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFC14A), HalloweenColors.muteOrange],
              ),
              border: Border.all(color: const Color(0xFFFFE08A), width: 2),
              boxShadow: [
                BoxShadow(
                  color: HalloweenColors.orange.withValues(alpha: 0.45),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
