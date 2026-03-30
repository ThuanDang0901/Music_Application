import 'package:flutter/material.dart';
import 'package:flutter_application_1/module/presentation/cubit/music_cubit.dart';
import 'package:flutter_application_1/module/presentation/cubit/music_state.dart';
import 'package:flutter_application_1/module/presentation/cubit/theme_cubit.dart';
import 'package:flutter_application_1/module/presentation/pages/detail_music.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final bgColor = isDark ? const Color(0xFF131E3A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white54 : Colors.black54;
    final iconColor = isDark ? Colors.white : Colors.black87;
    final sliderActiveColor = isDark ? Colors.white : Colors.blue;
    final sliderInactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.grey[300];

    return BlocBuilder<MusicCubit, MusicState>(
      builder: (context, state) {
        if (state is! MusicLoaded || state.currentSong == null) {
          return SizedBox.shrink();
        }
        final song = state.currentSong!;
        final maxDuration = state.totalDuration.inSeconds > 0
            ? state.totalDuration.inSeconds.toDouble()
            : 1.0;
        final currentPos = state.currentPosition.inSeconds.toDouble().clamp(
          0.0,
          maxDuration,
        );
        return InkWell(
          onTap: () {
            final currentIndex = state.playlistSongs.indexOf(
              state.currentSong!,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailMusic(
                  playlist: state.recommendedSongs,
                  initialIndex: currentIndex != 1 ? currentIndex : 0,
                ),
              ),
            );
          },
          child: Container(
            color: bgColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.translate(
                  offset: const Offset(0, -10),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2.0,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 10.0,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12.0,
                      ),
                      activeTrackColor: sliderActiveColor,
                      inactiveTrackColor: sliderInactiveColor,
                      thumbColor: sliderActiveColor,
                    ),
                    child: Slider(
                      min: 0.0,
                      max: maxDuration,
                      value: currentPos,
                      onChanged: (value) {
                        context.read<MusicCubit>().seek(
                          Duration(seconds: value.toInt()),
                        );
                      },
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(song.imageUrl, scale: 15),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                song.artist,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.skip_previous, color: iconColor),
                              onPressed: () {
                                context.read<MusicCubit>().playPrevious();
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                state.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: iconColor,
                                size: 32,
                              ),
                              onPressed: () {
                                context.read<MusicCubit>().PauseOrResume();
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.skip_next, color: iconColor),
                              onPressed: () {
                                context.read<MusicCubit>().playNext();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
