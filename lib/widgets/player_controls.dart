import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../provider/audio_provider.dart';
import '../utils/constants.dart';

class PlayerControls extends StatelessWidget {
  final AudioProvider provider;

  const PlayerControls({Key? key, required this.provider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Secondary controls: shuffle & repeat
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                Icons.shuffle,
                color: provider.isShuffleEnabled
                    ? AppColors.primary
                    : AppColors.grey,
                size: AppSizes.secondaryControlSize,
              ),
              onPressed: () => provider.toggleShuffle(),
            ),
            const SizedBox(width: 80),
            _buildRepeatButton(),
          ],
        ),
        const SizedBox(height: 16),
        // Main controls: previous, play/pause, next
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(
                Icons.skip_previous,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () => provider.previous(),
            ),
            StreamBuilder<bool>(
              stream: provider.playingStream,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data ?? false;
                return GestureDetector(
                  onTap: () => provider.playPause(),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.white, size: 40),
              onPressed: () => provider.next(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRepeatButton() {
    IconData icon;
    Color color;

    switch (provider.loopMode) {
      case LoopMode.off:
        icon = Icons.repeat;
        color = AppColors.grey;
        break;
      case LoopMode.all:
        icon = Icons.repeat;
        color = AppColors.primary;
        break;
      case LoopMode.one:
        icon = Icons.repeat_one;
        color = AppColors.primary;
        break;
    }

    return IconButton(
      icon: Icon(icon, color: color, size: AppSizes.secondaryControlSize),
      onPressed: () => provider.toggleRepeat(),
    );
  }
}
