import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../provider/playlist_provider.dart';
import '../utils/constants.dart';
import '../utils/duration_formatter.dart';
import 'album_art.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;
  final bool isCurrentSong;

  const SongTile({
    Key? key,
    required this.song,
    required this.onTap,
    this.isCurrentSong = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        children: [
          AlbumArtWidget(
            albumArtPath: song.albumArt,
            songId: song.id,
            size: 52,
          ),
          if (isCurrentSong)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppSizes.albumArtBorderRadius),
                ),
                child: const Icon(
                  Icons.equalizer,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        song.title,
        style: TextStyle(
          color: isCurrentSong ? AppColors.primary : Colors.white,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${song.artist}${song.duration != null ? ' • ${DurationFormatter.format(song.duration!)}' : ''}',
        style: const TextStyle(color: AppColors.grey, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, color: AppColors.grey),
        onPressed: () => _showOptionsMenu(context),
      ),
      onTap: onTap,
    );
  }

  void _showOptionsMenu(BuildContext context) {
    final playlists = context.read<PlaylistProvider>().playlists;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greyDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Song info header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    AlbumArtWidget(albumArtPath: song.albumArt, songId: song.id, size: 48),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(song.title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text(song.artist,
                              style: const TextStyle(color: AppColors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.greyDark, height: 1),
              ListTile(
                leading:
                    const Icon(Icons.playlist_add, color: Colors.white),
                title: const Text('Add to playlist',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddToPlaylist(context, playlists);
                },
              ),
              ListTile(
                leading: const Icon(Icons.play_arrow, color: Colors.white),
                title: const Text('Play next',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  // Could implement play next queue
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.info_outline, color: Colors.white),
                title: const Text('Song info',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showSongInfo(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddToPlaylist(BuildContext context, playlists) {
    if (playlists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No playlists found. Create one first!')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Add to Playlist',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
            ...playlists.map((playlist) => ListTile(
                  leading: const Icon(Icons.queue_music, color: AppColors.grey),
                  title: Text(playlist.name,
                      style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    context
                        .read<PlaylistProvider>()
                        .addSongToPlaylist(playlist.id, song.id);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Added to ${playlist.name}'),
                          backgroundColor: AppColors.primary),
                    );
                  },
                )),
          ],
        );
      },
    );
  }

  void _showSongInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Song Info',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Title', song.title),
            _infoRow('Artist', song.artist),
            _infoRow('Album', song.album ?? 'Unknown'),
            if (song.duration != null)
              _infoRow('Duration', DurationFormatter.format(song.duration!)),
            if (song.fileSize != null)
              _infoRow('Size', DurationFormatter.formatFileSize(song.fileSize!)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text('$label:',
                style: const TextStyle(
                    color: AppColors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}