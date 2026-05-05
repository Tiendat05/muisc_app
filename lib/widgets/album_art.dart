import 'dart:io';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../utils/constants.dart';

class AlbumArtWidget extends StatelessWidget {
  final String? albumArtPath;
  final String? songId;
  final double size;
  final double borderRadius;
  final bool showShadow;

  const AlbumArtWidget({
    Key? key,
    this.albumArtPath,
    this.songId,
    required this.size,
    this.borderRadius = AppSizes.albumArtBorderRadius,
    this.showShadow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget artWidget;

    if (albumArtPath != null && File(albumArtPath!).existsSync()) {
      artWidget = Image.file(
        File(albumArtPath!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildDefaultArt(),
      );
    } else if (songId != null) {
      artWidget = QueryArtworkWidget(
        id: int.tryParse(songId!) ?? 0,
        type: ArtworkType.AUDIO,
        quality: 100,
        size: size.toInt(),
        keepOldArtwork: true,
        nullArtworkWidget: _buildDefaultArt(),
        errorBuilder: (_, __, ___) => _buildDefaultArt(),
      );
    } else {
      artWidget = _buildDefaultArt();
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: artWidget,
      ),
    );
  }

  Widget _buildDefaultArt() {
    return Container(
      color: AppColors.surface,
      child: Icon(Icons.music_note, size: size * 0.4, color: AppColors.grey),
    );
  }
}
