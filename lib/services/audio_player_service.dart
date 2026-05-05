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
      if (filePath.startsWith('assets/')) {
        await _audioPlayer.setAsset(filePath);
      } else {
        await _audioPlayer.setFilePath(filePath);
      }
    } catch (e) {
      throw Exception('Error loading audio: $e');
    }
  }

  Future<void> play() async {
    await _audioPlayer.play();
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
