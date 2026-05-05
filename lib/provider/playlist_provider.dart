// lib/providers/playlist_provider.dart
import 'package:flutter/material.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../services/storage_service.dart';

class PlaylistProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<PlaylistModel> _playlists = [];

  PlaylistProvider(this._storageService) {
    _loadPlaylists();
  }

  List<PlaylistModel> get playlists => _playlists;

  Future<void> _loadPlaylists() async {
    _playlists = await _storageService.getPlaylists();
    notifyListeners();
  }

  Future<void> createPlaylist(String name) async {
    final playlist = PlaylistModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      songIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _playlists.add(playlist);
    await _save();
  }

  Future<void> deletePlaylist(String id) async {
    _playlists.removeWhere((p) => p.id == id);
    await _save();
  }

  Future<void> renamePlaylist(String id, String newName) async {
    final index = _playlists.indexWhere((p) => p.id == id);
    if (index != -1) {
      _playlists[index] = _playlists[index].copyWith(name: newName);
      await _save();
    }
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final playlist = _playlists[index];
      if (!playlist.songIds.contains(songId)) {
        final updatedIds = List<String>.from(playlist.songIds)..add(songId);
        _playlists[index] = playlist.copyWith(songIds: updatedIds);
        await _save();
      }
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final updatedIds = List<String>.from(_playlists[index].songIds)
        ..remove(songId);
      _playlists[index] = _playlists[index].copyWith(songIds: updatedIds);
      await _save();
    }
  }

  List<SongModel> getSongsForPlaylist(
    PlaylistModel playlist,
    List<SongModel> allSongs,
  ) {
    return playlist.songIds
        .map(
          (id) => allSongs.firstWhere(
            (s) => s.id == id,
            orElse: () => SongModel(
              id: id,
              title: 'Unknown',
              artist: 'Unknown',
              filePath: '',
            ),
          ),
        )
        .where((s) => s.filePath.isNotEmpty)
        .toList();
  }

  Future<void> _save() async {
    await _storageService.savePlaylists(_playlists);
    notifyListeners();
  }
}
