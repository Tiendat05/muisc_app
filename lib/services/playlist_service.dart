import 'dart:typed_data';
import 'package:on_audio_query/on_audio_query.dart';
import '../models/song_model.dart' as song_model;

class PlaylistService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<List<song_model.SongModel>> getAllSongs() async {
    try {
      final List<SongModel> audioList = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );
      return audioList
          .map((audio) => song_model.SongModel.fromAudioQuery(audio))
          .where(
            (song) => song.duration != null && song.duration!.inSeconds > 10,
          )
          .toList();
    } catch (e) {
      throw Exception('Error loading songs: $e');
    }
  }

  Future<List<song_model.SongModel>> getSongsByArtist(String artist) async {
    final allSongs = await getAllSongs();
    return allSongs.where((song) => song.artist == artist).toList();
  }

  Future<List<song_model.SongModel>> getSongsByAlbum(String album) async {
    final allSongs = await getAllSongs();
    return allSongs.where((song) => song.album == album).toList();
  }

  Future<List<song_model.SongModel>> searchSongs(String query) async {
    final allSongs = await getAllSongs();
    final lowerQuery = query.toLowerCase();
    return allSongs.where((song) {
      return song.title.toLowerCase().contains(lowerQuery) ||
          song.artist.toLowerCase().contains(lowerQuery) ||
          (song.album?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  Future<List<String>> getArtists() async {
    final allSongs = await getAllSongs();
    return allSongs.map((s) => s.artist).toSet().toList()..sort();
  }

  Future<List<String>> getAlbums() async {
    final allSongs = await getAllSongs();
    return allSongs
        .where((s) => s.album != null)
        .map((s) => s.album!)
        .toSet()
        .toList()
      ..sort();
  }

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
