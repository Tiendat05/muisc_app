import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playlist_model.dart';
import '../provider/playlist_provider.dart';
import '../provider/audio_provider.dart';
import '../services/playlist_service.dart';
import '../utils/constants.dart';
import '../widgets/playlist_card.dart';
import 'now_playing_screen.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final PlaylistService _playlistService = PlaylistService();
  final TextEditingController _playlistNameController = TextEditingController();

  @override
  void dispose() {
    _playlistNameController.dispose();
    super.dispose();
  }

  void _showCreatePlaylistDialog() {
    _playlistNameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Create Playlist',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: _playlistNameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Playlist name',
            hintStyle: TextStyle(color: AppColors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              if (_playlistNameController.text.isNotEmpty) {
                context.read<PlaylistProvider>().createPlaylist(
                  _playlistNameController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Create',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _playPlaylist(PlaylistModel playlist) async {
    try {
      final allSongs = await _playlistService.getAllSongs();
      final playlistSongs = allSongs
          .where((song) => playlist.songIds.contains(song.id))
          .toList();

      if (playlistSongs.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Playlist is empty')));
        return;
      }

      context.read<AudioProvider>().setPlaylist(playlistSongs, 0);
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const NowPlayingScreen()));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error playing playlist: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Playlists',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: _showCreatePlaylistDialog,
          ),
        ],
      ),
      body: Consumer<PlaylistProvider>(
        builder: (context, playlistProvider, _) {
          final playlists = playlistProvider.playlists;

          if (playlists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.playlist_play, size: 64, color: AppColors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No playlists yet',
                    style: TextStyle(color: AppColors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _showCreatePlaylistDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Create Playlist',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return PlaylistCard(
                playlist: playlist,
                onTap: () => _playPlaylist(playlist),
                onDelete: () {
                  context.read<PlaylistProvider>().deletePlaylist(playlist.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${playlist.name} deleted')),
                  );
                },
                onRename: () {
                  _playlistNameController.text = playlist.name;
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      title: const Text(
                        'Rename Playlist',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: TextField(
                        controller: _playlistNameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: AppColors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: AppColors.grey),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            if (_playlistNameController.text.isNotEmpty) {
                              context.read<PlaylistProvider>().renamePlaylist(
                                playlist.id,
                                _playlistNameController.text,
                              );
                              Navigator.pop(context);
                            }
                          },
                          child: const Text(
                            'Rename',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
