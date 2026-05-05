class SongModel {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String filePath;
  final Duration? duration;
  final String? albumArt;
  final int? fileSize;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    required this.filePath,
    this.duration,
    this.albumArt,
    this.fileSize,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      album: json['album'],
      filePath: json['filePath'],
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'])
          : null,
      albumArt: json['albumArt'],
      fileSize: json['fileSize'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'filePath': filePath,
      'duration': duration?.inMilliseconds,
      'albumArt': albumArt,
      'fileSize': fileSize,
    };
  }

  factory SongModel.fromAudioQuery(dynamic audioModel) {
    return SongModel(
      id: audioModel.id.toString(),
      title: audioModel.title ?? 'Unknown Title',
      artist: audioModel.artist ?? 'Unknown Artist',
      album: audioModel.album,
      filePath: audioModel.data,
      duration: Duration(milliseconds: audioModel.duration ?? 0),
    );
  }

  SongModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? filePath,
    Duration? duration,
    String? albumArt,
    int? fileSize,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      albumArt: albumArt ?? this.albumArt,
      fileSize: fileSize ?? this.fileSize,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SongModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
