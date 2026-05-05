import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1DB954);
  static const Color background = Color(0xFF191414);
  static const Color surface = Color(0xFF282828);
  static const Color surfaceLight = Color(0xFF383838);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF9B9B9B);
  static const Color greyDark = Color(0xFF535353);
  static const Color accent = Color(0xFF1ED760);
}

class AppSizes {
  static const double miniPlayerHeight = 80.0;
  static const double albumArtBorderRadius = 8.0;
  static const double mainControlSize = 48.0;
  static const double secondaryControlSize = 40.0;
  static const double screenPadding = 16.0;
}

class AppStrings {
  static const String appName = 'My Music';
  static const String nowPlaying = 'Now Playing';
  static const String noSongsFound = 'No Music Found';
  static const String addMusicMessage = 'Add some music files to your device';
  static const String permissionRequired = 'Storage Permission Required';
  static const String permissionMessage =
      'Please grant storage permission to access your music library';
}
