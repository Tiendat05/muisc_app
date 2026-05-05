import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/duration_formatter.dart';

class ProgressBarWidget extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final Function(Duration) onSeek;

  const ProgressBarWidget({
    Key? key,
    required this.position,
    required this.duration,
    required this.onSeek,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxVal = duration.inMilliseconds.toDouble().clamp(
      1.0,
      double.infinity,
    );
    final currentVal = position.inMilliseconds.toDouble().clamp(0.0, maxVal);

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.greyDark,
            thumbColor: Colors.white,
            overlayColor: AppColors.primary.withOpacity(0.3),
          ),
          child: Slider(
            value: currentVal,
            min: 0.0,
            max: maxVal,
            onChanged: (value) {
              onSeek(Duration(milliseconds: value.toInt()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DurationFormatter.format(position),
                style: const TextStyle(color: AppColors.grey, fontSize: 12),
              ),
              Text(
                DurationFormatter.format(duration),
                style: const TextStyle(color: AppColors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
