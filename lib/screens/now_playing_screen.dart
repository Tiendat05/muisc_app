import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/audio_provider.dart';
import '../utils/constants.dart';
import '../widgets/album_art.dart';
import '../widgets/player_controls.dart';
import '../widgets/progress_bar.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(AppStrings.nowPlaying),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Consumer<AudioProvider>(
        builder: (context, audioProvider, _) {
          final currentSong = audioProvider.currentSong;

          if (currentSong == null) {
            return const Center(child: Text('No song playing'));
          }

          return Column(
            children: [
              // Top spacing for AppBar
              const SizedBox(height: 60),

              // Album art
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: AlbumArtWidget(
                    albumArtPath: currentSong.albumArt,
                    songId: currentSong.id,
                    size: 280,
                    borderRadius: 16,
                    showShadow: true,
                  ),
                ),
              ),

              // Song info
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    Text(
                      currentSong.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentSong.artist,
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StreamBuilder<Duration>(
                  stream: audioProvider.positionStream,
                  builder: (context, posSnapshot) {
                    final position = posSnapshot.data ?? Duration.zero;
                    return StreamBuilder<Duration?>(
                      stream: audioProvider.durationStream,
                      builder: (context, durSnapshot) {
                        final duration = durSnapshot.data ?? Duration.zero;
                        return ProgressBarWidget(
                          position: position,
                          duration: duration,
                          onSeek: (position) => audioProvider.seek(position),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Player controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PlayerControls(provider: audioProvider),
              ),

              const SizedBox(height: 32),

              // Volume control
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Volume',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8,
                        ),
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: AppColors.greyDark,
                        thumbColor: Colors.white,
                      ),
                      child: Slider(
                        value: audioProvider.volume,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (value) => audioProvider.setVolume(value),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}
