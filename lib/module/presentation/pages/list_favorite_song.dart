import 'package:flutter/material.dart';
import 'package:flutter_application_1/module/presentation/cubit/music_cubit.dart';
import 'package:flutter_application_1/module/presentation/cubit/music_state.dart';
import 'package:flutter_application_1/module/presentation/cubit/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListFavoriteSong extends StatelessWidget {
  const ListFavoriteSong({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;

    final bgColor = isDark ? Color(0xFF0091227) : Color(0xFFEAF0FF);
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.white10 : Colors.black38;
    final iconColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text(
          "Favorite Songs",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocBuilder<MusicCubit, MusicState>(
          builder: (context, state) {
            if (state is MusicLoaded) {
              final favorites = state.favoriteSongs;

              // Nếu danh sách trống
              if (favorites.isEmpty) {
                return Center(
                  child: Text(
                    "You have No liked any Song",
                    style: TextStyle(color: textColor, fontSize: 16),
                  ),
                );
              }
              return ListView.builder(
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final song = favorites[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        song.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      song.title,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      song.artist,
                      style: TextStyle(color: subTextColor),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.favorite, color: iconColor),
                      onPressed: () {
                        context.read<MusicCubit>().ControlFavoriteSong(song);
                      },
                    ),
                    onTap: () {
                      // Bấm vào bài hát thì phát nhạc luôn
                      context.read<MusicCubit>().playMusic(song);
                    },
                  );
                },
              );
            }
            return Center(child: CircularProgressIndicator(color: bgColor));
          },
        ),
      ),
    );
  }
}
