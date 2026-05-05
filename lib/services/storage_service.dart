import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist_model.dart';

class StorageService {
  static const String _playlistsKey = 'playlists';
  static const String _lastPlayedKey = 'last_played';
  static const String _lastPositionKey = 'last_position';
  static const String _shuffleKey = 'shuffle_enabled';
  static const String _repeatKey = 'repeat_mode';
  static const String _volumeKey = 'volume';
  static const String _recentlyPlayedKey = 'recently_played';

  Future<void> savePlaylists(List<PlaylistModel> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsJson = playlists.map((p) => p.toJson()).toList();
    await prefs.setString(_playlistsKey, json.encode(playlistsJson));
  }

  Future<List<PlaylistModel>> getPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsString = prefs.getString(_playlistsKey);
    if (playlistsString != null) {
      final List<dynamic> playlistsJson = json.decode(playlistsString);
      return playlistsJson.map((j) => PlaylistModel.fromJson(j)).toList();
    }
    return [];
  }

  Future<void> saveLastPlayed(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastPlayedKey, songId);
  }

  Future<String?> getLastPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastPlayedKey);
  }

  Future<void> saveLastPosition(int milliseconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastPositionKey, milliseconds);
  }

  Future<int> getLastPosition() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastPositionKey) ?? 0;
  }

  Future<void> saveShuffleState(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shuffleKey, enabled);
  }

  Future<bool> getShuffleState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_shuffleKey) ?? false;
  }

  Future<void> saveRepeatMode(int mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_repeatKey, mode);
  }

  Future<int> getRepeatMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_repeatKey) ?? 0;
  }

  Future<void> saveVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, volume);
  }

  Future<double> getVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_volumeKey) ?? 1.0;
  }

  Future<void> addToRecentlyPlayed(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    final recentString = prefs.getString(_recentlyPlayedKey);
    List<String> recent = recentString != null
        ? List<String>.from(json.decode(recentString))
        : [];
    recent.remove(songId);
    recent.insert(0, songId);
    if (recent.length > 20) recent = recent.take(20).toList();
    await prefs.setString(_recentlyPlayedKey, json.encode(recent));
  }

  Future<List<String>> getRecentlyPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    final recentString = prefs.getString(_recentlyPlayedKey);
    if (recentString != null) {
      return List<String>.from(json.decode(recentString));
    }
    return [];
  }
}
