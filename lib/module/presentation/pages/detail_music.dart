import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/module/domain/entities/song.dart';
import 'package:flutter_application_1/module/presentation/cubit/music_cubit.dart';
import 'package:flutter_application_1/module/presentation/cubit/music_state.dart';
import 'package:flutter_application_1/module/presentation/cubit/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailMusic extends StatefulWidget {
  final List<Song> playlist;
  final int initialIndex;
  const DetailMusic({
    super.key,
    required this.playlist,
    required this.initialIndex,
  });

  @override
  State<DetailMusic> createState() => _DetailMusicState();
}

class _DetailMusicState extends State<DetailMusic> {
  late int currentIndex;
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

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
    // final currentSong = widget.playlist[currentIndex];
    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        child: SafeArea(
          child: BlocConsumer<MusicCubit, MusicState>(
            listener: (context, state) {
              if (state is MusicLoaded && state.currentSong != null) {
                final songIndex = widget.playlist.indexOf(state.currentSong!);
                if (songIndex != -1 && songIndex != currentIndex) {
                  currentIndex = songIndex;
                  _carouselController.animateToPage(
                    songIndex,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              }
            },
            builder: (context, state) {
              if (state is MusicLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              } else if (state is MusicLoaded) {
                final maxDuration = state.totalDuration.inSeconds > 0
                    ? state.totalDuration.inSeconds.toDouble()
                    : 1.0;
                final currentPos = state.currentPosition.inSeconds
                    .toDouble()
                    .clamp(0.0, maxDuration);
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsetsGeometry.symmetric(
                          horizontal: 10.0,
                          vertical: 10.0,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.arrow_back, color: iconColor),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Playing Now",
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      CarouselSlider.builder(
                        carouselController: _carouselController,
                        itemCount: widget.playlist.length,
                        itemBuilder: (context, index, realIndex) {
                          final song = widget.playlist[index];
                          return Column(
                            children: [
                              Image.asset(
                                song.imageUrl,
                                fit: BoxFit.cover,
                                height: 300,
                                width: 300,
                              ),
                              SizedBox(height: 28),
                              SizedBox(
                                width: 300,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          song.title,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          song.artist,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                            color: textColor,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: IconButton(
                                        onPressed: () {
                                          context
                                              .read<MusicCubit>()
                                              .ControlFavoriteSong(song);
                                        },
                                        icon: Icon(
                                          state.favoriteSongs.contains(song)
                                              ? Icons.favorite
                                              : Icons.favorite_border_outlined,
                                          color: iconColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        options: CarouselOptions(
                          height: 450,
                          viewportFraction: 0.75,
                          initialPage: widget.initialIndex,
                          enlargeCenterPage: true,
                          enlargeFactor: 0.25,
                          enableInfiniteScroll: false,
                          onPageChanged: (index, reason) {
                            currentIndex = index;
                            if (reason == CarouselPageChangedReason.manual) {
                              final selectedSong = widget.playlist[index];
                              context.read<MusicCubit>().playMusic(
                                selectedSong,
                              );
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.volume_up,
                                    color: subTextColor,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        context
                                            .read<MusicCubit>()
                                            .ControlRepeat();
                                      },
                                      icon: Icon(
                                        state.isRepeat
                                            ? Icons.repeat_one
                                            : Icons.repeat,
                                        color: subTextColor,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.shuffle,
                                        color: subTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(state.currentPosition),
                                      style: TextStyle(color: subTextColor),
                                    ),
                                    Text(
                                      _formatDuration(state.totalDuration),
                                      style: TextStyle(color: subTextColor),
                                    ),
                                  ],
                                ),
                                Slider(
                                  value: currentPos,
                                  max: maxDuration,
                                  min: 0.0,
                                  onChanged: (value) {
                                    context.read<MusicCubit>().seek(
                                      Duration(seconds: value.toInt()),
                                    );
                                  },
                                  activeColor: sliderActiveColor,
                                  inactiveColor: sliderInactiveColor,
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        context
                                            .read<MusicCubit>()
                                            .playPrevious();
                                      },
                                      icon: Icon(
                                        Icons.skip_previous,
                                        color: iconColor,
                                        size: 40,
                                      ),
                                    ),
                                    const SizedBox(width: 30),
                                    IconButton(
                                      onPressed: () {
                                        context
                                            .read<MusicCubit>()
                                            .PauseOrResume();
                                      },
                                      icon: Icon(
                                        state.isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: iconColor,
                                        size: 50,
                                      ),
                                    ),
                                    const SizedBox(width: 30),
                                    IconButton(
                                      onPressed: () {
                                        context.read<MusicCubit>().playNext();
                                      },
                                      icon: Icon(
                                        Icons.skip_next,
                                        color: iconColor,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
