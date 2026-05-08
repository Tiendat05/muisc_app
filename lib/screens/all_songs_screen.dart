import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../provider/audio_provider.dart';
import '../services/playlist_service.dart';
import '../services/permission_service.dart';
import '../utils/constants.dart';
import '../widgets/song_tile.dart';
import 'now_playing_screen.dart';

class AllSongsScreen extends StatefulWidget {
  const AllSongsScreen({Key? key}) : super(key: key);

  @override
  State<AllSongsScreen> createState() => _AllSongsScreenState();
}

class _AllSongsScreenState extends State<AllSongsScreen> {
  final PlaylistService _playlistService = PlaylistService();
  final PermissionService _permissionService = PermissionService();

  List<SongModel> _allSongs = [];
  List<SongModel> _filteredSongs = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllSongs();
    });
  }

  Future<void> _loadAllSongs() async {
    final hasPermission = await _permissionService.requestAudioPermission();

    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio permission is required')),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    try {
      final songs = await _playlistService.getAllSongs();

      if (!mounted) return;

      setState(() {
        _allSongs = songs;
        _filteredSongs = songs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading songs: $e')));
    }
  }

  void _filterSongs(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredSongs = _allSongs;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredSongs = _allSongs.where((song) {
          return song.title.toLowerCase().contains(lowerQuery) ||
              song.artist.toLowerCase().contains(lowerQuery) ||
              (song.album?.toLowerCase().contains(lowerQuery) ?? false);
        }).toList();
      }
    });
  }

  void _playSong(int index) {
    final audioProvider = context.read<AudioProvider>();
    final songIndex = _allSongs.indexWhere(
      (s) => s.id == _filteredSongs[index].id,
    );

    if (songIndex != -1) {
      audioProvider.setPlaylist(_allSongs, songIndex);
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const NowPlayingScreen()));
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
          'All Songs',
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
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _allSongs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_note, size: 64, color: AppColors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No songs found on your device',
                    style: TextStyle(color: AppColors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search songs...',
                      hintStyle: TextStyle(color: AppColors.grey),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.primary,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: AppColors.primary,
                              ),
                              onPressed: () => _filterSongs(''),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.grey),
                      ),
                    ),
                    onChanged: _filterSongs,
                  ),
                ),

                // Song count
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '${_filteredSongs.length} songs',
                    style: TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
                ),

                // Songs list
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredSongs.length,
                    itemBuilder: (context, index) {
                      final song = _filteredSongs[index];
                      return SongTile(
                        song: song,
                        isCurrentSong:
                            context.watch<AudioProvider>().currentSong?.id ==
                            song.id,
                        onTap: () => _playSong(index),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
