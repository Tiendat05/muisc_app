import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../provider/audio_provider.dart';
import '../services/playlist_service.dart';
import '../services/permission_service.dart';
import '../utils/constants.dart';
import '../widgets/song_tile.dart';
import 'now_playing_screen.dart';
import 'zing_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlaylistService _playlistService = PlaylistService();
  final PermissionService _permissionService = PermissionService();

  List<SongModel> _allSongs = [];
  List<SongModel> _filteredSongs = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // ✅ FIX crash permission
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSongs();
    });
  }

  Future<void> _loadSongs() async {
    // ✅ dùng audio permission
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

      // load vào player
      if (songs.isNotEmpty) {
        context.read<AudioProvider>().setPlaylist(songs, 0);
      }
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
          AppStrings.appName,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _allSongs.isEmpty
          ? Center(
              child: Text(
                "No songs found",
                style: TextStyle(color: AppColors.grey),
              ),
            )
          : Column(
              children: [
                // 🔍 Search
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: AppColors.grey),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.grey,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _filterSongs,
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredSongs.length,
                    itemBuilder: (context, index) {
                      final song = _filteredSongs[index];

                      return Consumer<AudioProvider>(
                        builder: (context, audioProvider, _) {
                          final isCurrent =
                              audioProvider.currentSong?.id == song.id;

                          return SongTile(
                            song: song,
                            isCurrentSong: isCurrent,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ZingPlayer(),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
