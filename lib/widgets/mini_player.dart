import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/audio_provider.dart';
import '../utils/constants.dart';
import 'album_art.dart';

class MiniPlayer extends StatelessWidget {
  final VoidCallback onTap;

  const MiniPlayer({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, _) {
        final currentSong = audioProvider.currentSong;

        if (currentSong == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: onTap,
          child: Container(
            height: AppSizes.miniPlayerHeight,
            color: AppColors.surface,
            child: Column(
              children: [
                // Progress bar
                StreamBuilder<bool>(
                  stream: audioProvider.playingStream,
                  builder: (context, snapshot) {
                    return Container(
                      height: 2,
                      color: AppColors.primary.withOpacity(0.3),
                      child: StreamBuilder<Duration>(
                        stream: audioProvider.positionStream,
                        builder: (context, posSnapshot) {
                          final position = posSnapshot.data ?? Duration.zero;
                          return StreamBuilder<Duration?>(
                            stream: audioProvider.durationStream,
                            builder: (context, durSnapshot) {
                              final duration =
                                  durSnapshot.data ?? Duration.zero;
                              final progress = duration.inMilliseconds > 0
                                  ? position.inMilliseconds /
                                        duration.inMilliseconds
                                  : 0.0;
                              return FractionallySizedBox(
                                widthFactor: progress.clamp(0.0, 1.0),
                                child: Container(color: AppColors.primary),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
                // Player content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        // Album art
                        AlbumArtWidget(
                          albumArtPath: currentSong.albumArt,
                          songId: currentSong.id,
                          size: 56,
                          borderRadius: 4,
                        ),
                        const SizedBox(width: 12),
                        // Song info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                currentSong.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                currentSong.artist,
                                style: const TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Controls
                        StreamBuilder<bool>(
                          stream: audioProvider.playingStream,
                          builder: (context, snapshot) {
                            final isPlaying = snapshot.data ?? false;
                            return IconButton(
                              icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                              ),
                              onPressed: () => audioProvider.playPause(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
