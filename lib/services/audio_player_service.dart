import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import '../models/playback_state_model.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Streams
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<bool> get playingStream => _audioPlayer.playingStream;

  // Current state getters
  Duration get currentPosition => _audioPlayer.position;
  Duration? get currentDuration => _audioPlayer.duration;
  bool get isPlaying => _audioPlayer.playing;

  // Combined playback state stream
  Stream<PlaybackStateModel> get playbackStateStream {
    return Rx.combineLatest3<Duration, Duration?, bool, PlaybackStateModel>(
      positionStream,
      durationStream,
      playingStream,
      (position, duration, isPlaying) => PlaybackStateModel(
        position: position,
        duration: duration ?? Duration.zero,
        isPlaying: isPlaying,
      ),
    );
  }

  // Load and play audio from file path
  Future<void> loadAudio(String filePath) async {
    try {
      debugPrint('[AudioService] Loading audio: $filePath');
      if (filePath.startsWith('assets/')) {
        // Remove 'assets/' prefix for setAsset()
        final assetPath = filePath.replaceFirst('assets/', '');
        debugPrint('[AudioService] Loading asset: $assetPath');
        await _audioPlayer.setAsset(assetPath);
      } else {
        debugPrint('[AudioService] Loading file path: $filePath');
        await _audioPlayer.setFilePath(filePath);
      }
      debugPrint('[AudioService] Audio loaded successfully');
      debugPrint('[AudioService] Duration: ${_audioPlayer.duration}');
    } catch (e) {
      debugPrint('[AudioService] Error loading audio: $e');
      throw Exception('Error loading audio: $e');
    }
  }

  Future<void> play() async {
    try {
      debugPrint('[AudioService] Playing...');
      await _audioPlayer.play();
      debugPrint('[AudioService] Now playing: ${_audioPlayer.playing}');
    } catch (e) {
      debugPrint('[AudioService] Error playing: $e');
      throw Exception('Error playing audio: $e');
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<void> setSpeed(double speed) async {
    await _audioPlayer.setSpeed(speed.clamp(0.5, 2.0));
  }

  Future<void> setLoopMode(LoopMode loopMode) async {
    await _audioPlayer.setLoopMode(loopMode);
  }

  // Listen for song completion
  Stream<PlayerState> get completionStream => _audioPlayer.playerStateStream;

  void dispose() {
    _audioPlayer.dispose();
  }
}
