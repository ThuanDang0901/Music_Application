import 'package:flutter/material.dart';
import 'package:flutter_application_1/module/domain/entities/album.dart';
import 'package:flutter_application_1/module/domain/entities/song.dart';
import 'package:flutter_application_1/module/presentation/cubit/music_cubit.dart';
import 'package:flutter_application_1/module/presentation/cubit/theme_cubit.dart';
import 'package:flutter_application_1/module/presentation/widget/mini_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlbumDetailPage extends StatelessWidget {
  final Album album;

  const AlbumDetailPage({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final bgColor = isDark ? const Color(0xFF091227) : const Color(0xFFEAF0FF);
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(album.name, style: TextStyle(color: textColor)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Phần thông tin Album
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    album.imageUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        album.name,
                        style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        album.artistName,
                        style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 16),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          
          // Danh sách bài hát
          Expanded(
            child: FutureBuilder<List<Song>>(
              future: context.read<MusicCubit>().getSongsForAlbum(album.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Không có bài hát nào.', style: TextStyle(color: textColor)));
                }

                final songs = snapshot.data!;
                return ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return ListTile(
                      leading: Text('${index + 1}', style: TextStyle(color: textColor.withValues(alpha: 0.5))),
                      title: Text(song.title, style: TextStyle(color: textColor), maxLines: 1),
                      subtitle: Text(song.artist, style: TextStyle(color: textColor.withValues(alpha: 0.5))),
                      trailing: Icon(Icons.play_arrow, color: textColor),
                      onTap: () {
                        // Gọi hàm phát nhạc và gán toàn bộ danh sách album vào currentQueue
                        context.read<MusicCubit>().playMusic(song, queue: songs);
                      },
                    );
                  },
                );
              },
            ),
          ),
          const MiniPlayer(), // Hiển thị MiniPlayer ở cuối
        ],
      ),
    );
  }
}