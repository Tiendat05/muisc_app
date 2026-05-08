import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../models/song_model.dart' as song_model;

class PlaylistService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  // Sample songs from assets
  static const List<Map<String, String>> _sampleSongs = [
    {
      'title': 'That Girl',
      'artist': 'Unknown Artist',
      'album': 'Demo Album',
      'path': 'assets/audio/sample_songs/That Girl.mp3',
    },
  ];

  /// Get all songs from device
  /// If none found -> fallback to sample asset songs
  Future<List<song_model.SongModel>> getAllSongs() async {
    try {
      final List<SongModel> audioList = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      List<song_model.SongModel> songs = audioList
          .map((audio) => song_model.SongModel.fromAudioQuery(audio))
          .where(
            (song) => song.duration != null && song.duration!.inSeconds > 10,
          )
          .toList();

      // Fallback to sample songs
      if (songs.isEmpty) {
        songs = await _getSampleSongs();
      }

      return songs;
    } catch (e) {
      // Return sample songs if query fails
      return await _getSampleSongs();
    }
  }

  /// Load sample songs and auto-read duration from mp3 asset
  Future<List<song_model.SongModel>> _getSampleSongs() async {
    final List<song_model.SongModel> songs = [];

    final AudioPlayer player = AudioPlayer();

    for (final entry in _sampleSongs.asMap().entries) {
      final index = entry.key;
      final song = entry.value;

      try {
        // Load asset
        await player.setAsset(song['path']!);

        // Read real duration from mp3
        final Duration duration = player.duration ?? Duration.zero;

        songs.add(
          song_model.SongModel(
            id: 'sample_$index',
            title: song['title']!,
            artist: song['artist']!,
            album: song['album'],
            filePath: song['path']!,
            duration: duration,
          ),
        );
      } catch (e) {
        // Fallback if duration read fails
        songs.add(
          song_model.SongModel(
            id: 'sample_$index',
            title: song['title']!,
            artist: song['artist']!,
            album: song['album'],
            filePath: song['path']!,
            duration: Duration.zero,
          ),
        );
      }
    }

    await player.dispose();

    return songs;
  }

  /// Get songs by artist
  Future<List<song_model.SongModel>> getSongsByArtist(String artist) async {
    final allSongs = await getAllSongs();

    return allSongs.where((song) => song.artist == artist).toList();
  }

  /// Get songs by album
  Future<List<song_model.SongModel>> getSongsByAlbum(String album) async {
    final allSongs = await getAllSongs();

    return allSongs.where((song) => song.album == album).toList();
  }

  /// Search songs
  Future<List<song_model.SongModel>> searchSongs(String query) async {
    final allSongs = await getAllSongs();

    final lowerQuery = query.toLowerCase();

    return allSongs.where((song) {
      return song.title.toLowerCase().contains(lowerQuery) ||
          song.artist.toLowerCase().contains(lowerQuery) ||
          (song.album?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Get all artists
  Future<List<String>> getArtists() async {
    final allSongs = await getAllSongs();

    return allSongs.map((s) => s.artist).toSet().toList()..sort();
  }

  /// Get all albums
  Future<List<String>> getAlbums() async {
    final allSongs = await getAllSongs();

    return allSongs
        .where((s) => s.album != null)
        .map((s) => s.album!)
        .toSet()
        .toList()
      ..sort();
  }

  /// Get artwork from device songs
  Future<Uint8List?> getArtwork(String songId) async {
    try {
      return await _audioQuery.queryArtwork(
        int.parse(songId),
        ArtworkType.AUDIO,
        quality: 100,
        size: 300,
      );
    } catch (e) {
      return null;
    }
  }
}
