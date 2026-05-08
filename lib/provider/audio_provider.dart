import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import '../models/playback_state_model.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayerService _audioService;
  final StorageService _storageService;

  List<SongModel> _playlist = [];
  List<SongModel> _originalPlaylist = [];
  int _currentIndex = 0;
  bool _isShuffleEnabled = false;
  LoopMode _loopMode = LoopMode.off;
  double _volume = 1.0;
  bool _isLoading = false;

  AudioProvider(this._audioService, this._storageService) {
    _init();
    _listenToPlayerState();
  }

  // Getters
  List<SongModel> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  SongModel? get currentSong =>
      _playlist.isEmpty ? null : _playlist[_currentIndex];
  bool get isShuffleEnabled => _isShuffleEnabled;
  LoopMode get loopMode => _loopMode;
  double get volume => _volume;
  bool get isLoading => _isLoading;

  Stream<Duration> get positionStream => _audioService.positionStream;
  Stream<Duration?> get durationStream => _audioService.durationStream;
  Stream<bool> get playingStream => _audioService.playingStream;
  Stream<PlaybackStateModel> get playbackStateStream =>
      _audioService.playbackStateStream;
  bool get isPlaying => _audioService.isPlaying;

  Future<void> _init() async {
    _isShuffleEnabled = await _storageService.getShuffleState();
    final repeatMode = await _storageService.getRepeatMode();
    _loopMode =
        LoopMode.values[repeatMode.clamp(0, LoopMode.values.length - 1)];
    await _audioService.setLoopMode(_loopMode);
    _volume = await _storageService.getVolume();
    await _audioService.setVolume(_volume);
    notifyListeners();
  }

  void _listenToPlayerState() {
    _audioService.completionStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (_loopMode == LoopMode.off) {
          next();
        }
      }
    });
  }

  Future<void> setPlaylist(List<SongModel> songs, int startIndex) async {
    _originalPlaylist = List.from(songs);
    if (_isShuffleEnabled) {
      _playlist = _shufflePlaylist(songs, startIndex);
      _currentIndex = 0;
    } else {
      _playlist = List.from(songs);
      _currentIndex = startIndex;
    }
    await _playSongAtIndex(_currentIndex);
    notifyListeners();
  }

  Future<void> playSong(SongModel song) async {
    final index = _playlist.indexWhere((s) => s.id == song.id);
    if (index != -1) {
      await _playSongAtIndex(index);
    } else {
      _playlist = [song];
      _currentIndex = 0;
      await _playSongAtIndex(0);
    }
  }

  Future<void> _playSongAtIndex(int index) async {
    if (index < 0 || index >= _playlist.length) return;
    _isLoading = true;
    notifyListeners();

    _currentIndex = index;
    final song = _playlist[index];

    try {
      debugPrint(
        '[AudioProvider] Playing song: ${song.title} - ${song.filePath}',
      );
      await _audioService.loadAudio(song.filePath);
      debugPrint('[AudioProvider] Audio loaded, now playing...');
      await _audioService.play();
      debugPrint('[AudioProvider] Play command sent');
      await _storageService.saveLastPlayed(song.id);
      await _storageService.addToRecentlyPlayed(song.id);
    } catch (e) {
      debugPrint('[AudioProvider] Error playing song: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> playPause() async {
    if (_audioService.isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.play();
    }
    notifyListeners();
  }

  Future<void> next() async {
    if (_playlist.isEmpty) return;
    if (_isShuffleEnabled) {
      _currentIndex = _getRandomIndex();
    } else {
      _currentIndex = (_currentIndex + 1) % _playlist.length;
    }
    await _playSongAtIndex(_currentIndex);
  }

  Future<void> previous() async {
    if (_playlist.isEmpty) return;
    if (_audioService.currentPosition.inSeconds > 3) {
      await _audioService.seek(Duration.zero);
    } else {
      if (_isShuffleEnabled) {
        _currentIndex = _getRandomIndex();
      } else {
        _currentIndex =
            (_currentIndex - 1 + _playlist.length) % _playlist.length;
      }
      await _playSongAtIndex(_currentIndex);
    }
  }

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }

  Future<void> toggleShuffle() async {
    _isShuffleEnabled = !_isShuffleEnabled;
    if (_isShuffleEnabled && _playlist.isNotEmpty) {
      final currentSongId = currentSong?.id;
      _playlist = _shufflePlaylist(_originalPlaylist, 0);
      if (currentSongId != null) {
        final newIndex = _playlist.indexWhere((s) => s.id == currentSongId);
        if (newIndex != -1) _currentIndex = newIndex;
      }
    } else {
      final currentSongId = currentSong?.id;
      _playlist = List.from(_originalPlaylist);
      if (currentSongId != null) {
        _currentIndex = _playlist.indexWhere((s) => s.id == currentSongId);
        if (_currentIndex == -1) _currentIndex = 0;
      }
    }
    await _storageService.saveShuffleState(_isShuffleEnabled);
    notifyListeners();
  }

  Future<void> toggleRepeat() async {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
        break;
      case LoopMode.all:
        _loopMode = LoopMode.one;
        break;
      case LoopMode.one:
        _loopMode = LoopMode.off;
        break;
    }
    await _audioService.setLoopMode(_loopMode);
    await _storageService.saveRepeatMode(_loopMode.index);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _audioService.setVolume(_volume);
    await _storageService.saveVolume(_volume);
    notifyListeners();
  }

  List<SongModel> _shufflePlaylist(List<SongModel> songs, int startIndex) {
    final shuffled = List<SongModel>.from(songs);
    final startSong = songs[startIndex];
    shuffled.remove(startSong);
    shuffled.shuffle(Random());
    shuffled.insert(0, startSong);
    return shuffled;
  }

  int _getRandomIndex() {
    if (_playlist.length <= 1) return 0;
    int newIndex;
    do {
      newIndex = Random().nextInt(_playlist.length);
    } while (newIndex == _currentIndex);
    return newIndex;
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
