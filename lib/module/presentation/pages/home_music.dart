import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_application_1/module/presentation/cubit/music_cubit.dart';
import 'package:flutter_application_1/module/presentation/cubit/music_state.dart';
import 'package:flutter_application_1/module/presentation/cubit/theme_cubit.dart';
import 'package:flutter_application_1/module/presentation/pages/detail_music.dart';
import 'package:flutter_application_1/module/presentation/pages/list_favorite_song.dart';
import 'package:flutter_application_1/module/presentation/widget/mini_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeMusic extends StatelessWidget {
  const HomeMusic({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;

    final bgColor = isDark ? Color(0xFF0091227) : Color(0xFFEAF0FF);
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.white10 : Colors.black38;
    final iconColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      drawer: Drawer(
        backgroundColor: bgColor,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close, color: iconColor, size: 28),
                    ),
                    IconButton(
                      onPressed: () {
                        context.read<ThemeCubit>().toggleTheme();
                      },
                      icon: Icon(
                        Icons.nightlight_round,
                        size: 28,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                // Các item Trong Cài Đặt
                InkWell(
                  onTap: () {},
                  child: Container(
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Icon(Icons.person, color: iconColor, size: 30),
                          ],
                        ),
                        SizedBox(width: 30),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Profile",
                              style: TextStyle(color: textColor, fontSize: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListFavoriteSong(),
                      ),
                    );
                  },
                  child: Container(
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Icon(
                              Icons.favorite_border_outlined,
                              color: iconColor,
                              size: 30,
                            ),
                          ],
                        ),
                        SizedBox(width: 30),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Liked Songs",
                              style: TextStyle(color: textColor, fontSize: 20),
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
        ),
      ),
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<MusicCubit, MusicState>(
                builder: (context, state) {
                  if (state is MusicLoading) {
                    return Center(
                      child: CircularProgressIndicator(color: iconColor),
                    );
                  } else if (state is MusicError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (state is MusicLoaded) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 24.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Builder(
                                  builder: (context) {
                                    return GestureDetector(
                                      onTap: () {
                                        Scaffold.of(context).openDrawer();
                                      },
                                      child: Icon(
                                        Icons.menu,
                                        color: iconColor,
                                        size: 28,
                                      ),
                                    );
                                  },
                                ),
                                Icon(Icons.search, color: iconColor, size: 28),
                              ],
                            ),
                          ),

                          Padding(
                            padding: EdgeInsetsGeometry.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Text(
                              "Recommended for you",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          //
                          CarouselSlider.builder(
                            itemCount: state.recommendedSongs.length,
                            itemBuilder: (context, index, realIndex) {
                              final song = state.recommendedSongs[index];
                              return GestureDetector(
                                onTap: () {
                                  context.read<MusicCubit>().playMusic(song);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailMusic(
                                        playlist: state.recommendedSongs,
                                        initialIndex: index,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 150,
                                  margin: const EdgeInsets.only(right: 15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 160,
                                        width: 160,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          image: DecorationImage(
                                            image: AssetImage(song.imageUrl),
                                            fit: BoxFit.cover,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.3,
                                              ),
                                              blurRadius: 10,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Tên bài hát
                                      Text(
                                        song.title,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      // Tên ca sĩ
                                      Text(
                                        song.artist,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },

                            options: CarouselOptions(
                              height: 220,
                              viewportFraction: 0.45,
                              enableInfiniteScroll: false,
                              initialPage: 0,
                              reverse: false,
                              padEnds: false,
                              autoPlay: false,
                              enlargeCenterPage: false,
                              disableCenter: true,
                            ),
                          ),
                          //
                          SizedBox(height: 20),
                          Padding(
                            padding: EdgeInsetsGeometry.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Text(
                              "My Playlist",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          CarouselSlider.builder(
                            itemCount: state.playlistSongs.length,
                            itemBuilder: (context, index, realIndex) {
                              final song = state.playlistSongs[index];
                              return Container(
                                width: 160,
                                margin: const EdgeInsets.only(right: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 160,
                                      width: 160,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        image: DecorationImage(
                                          image: AssetImage(song.imageUrl),
                                          fit: BoxFit.cover,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      song.title,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      song.artist,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              );
                            },
                            options: CarouselOptions(
                              height: 240,
                              viewportFraction: 0.45,
                              enableInfiniteScroll: false,
                              initialPage: 0,
                              reverse: false,
                              padEnds: false,
                              autoPlay: false,
                              enlargeCenterPage: false,
                              disableCenter: true,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ),
            MiniPlayer(),
          ],
        ),
      ),
    );
  }
}
