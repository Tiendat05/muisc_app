import 'dart:typed_data';
import 'package:flutter/material.dart';

class ColorExtractor {
  /// Extract dominant color from image bytes
  static Future<Color> extractDominantColor(Uint8List? imageBytes) async {
    if (imageBytes == null || imageBytes.isEmpty) {
      return Colors.grey;
    }

    try {
      await decodeImageFromList(imageBytes);
      // For simplicity, return a predefined color based on image size
      // In a production app, you'd use a proper image analysis library
      return Colors.blueGrey;
    } catch (e) {
      return Colors.grey;
    }
  }

  /// Get a list of colors from image for gradient
  static Future<List<Color>> extractGradientColors(
    Uint8List? imageBytes,
  ) async {
    if (imageBytes == null || imageBytes.isEmpty) {
      return [Colors.grey, Colors.grey.shade800];
    }

    try {
      final dominantColor = await extractDominantColor(imageBytes);
      return [dominantColor, dominantColor.withOpacity(0.6)];
    } catch (e) {
      return [Colors.grey, Colors.grey.shade800];
    }
  }
}
