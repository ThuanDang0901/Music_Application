import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/module/domain/entities/song.dart';
import 'package:flutter_application_1/module/presentation/cubit/music_cubit.dart';
import 'package:flutter_application_1/module/presentation/cubit/music_state.dart';
import 'package:flutter_application_1/module/presentation/cubit/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/module/data/repositories/comment_repo.dart'; 
import 'package:flutter_application_1/module/domain/entities/comment.dart';
import 'package:share_plus/share_plus.dart';

class DetailMusic extends StatefulWidget {
  final List<Song> playlist;
  final int initialIndex;
  final String? userId;
  const DetailMusic({
    super.key,
    required this.playlist,
    required this.initialIndex,
    required this.userId,
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

                            // 3. NÚT SHARE
                            IconButton(
                              onPressed: () {
                                if (state is MusicLoaded && state.currentSong != null) {
                                  final song = state.currentSong!;
                                  // Gọi bảng chia sẻ của điện thoại lên
                                  Share.share(
                                    'Đang nghe bài hát "${song.title}" của ${song.artist} cực chill.\n\nNghe thử ngay: ${song.audioUrl}'
                                  );
                                }
                              },
                              icon: Icon(Icons.share, color: iconColor),
                            ),

                            IconButton(
                            onPressed: () {
                              if (state is MusicLoaded && state.currentSong != null) {
                                _showCommentBottomSheet(context, state.currentSong!);
                              }
                            },
                            icon: Icon(Icons.comment, color: iconColor),
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
                              // Image.asset(
                              //   song.imageUrl,
                              //   fit: BoxFit.cover,
                              //   height: 300,
                              //   width: 300,
                              // ),
                              Image.network(
                                song.imageUrl,
                                fit: BoxFit.cover,
                                height: 300,
                                width: 300,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.album,
                                      size: 100,
                                      color: Colors.grey,
                                    ),
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
                                              .ControlFavoriteSong(
                                                song,
                                                userId: widget.userId,
                                              );
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
                              // === CỤM 1: ÂM LƯỢNG (Nằm sát nhau bên trái) ===
                              Row(
                                children: [
                                  Icon(
                                    state.volume == 0 
                                        ? Icons.volume_off 
                                        : (state.volume < 0.5 ? Icons.volume_down : Icons.volume_up),
                                    color: subTextColor,
                                  ),
                                  SizedBox(
                                    width: 100, // Khóa cứng chiều dài thanh gạt để không bị dãn
                                    child: Slider(
                                      value: state.volume,
                                      min: 0.0,
                                      max: 1.0,
                                      activeColor: sliderActiveColor,
                                      inactiveColor: sliderInactiveColor,
                                      onChanged: (value) {
                                        context.read<MusicCubit>().setVolume(value);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              
                              // === CỤM 2: LẶP LẠI & TRỘN BÀI (Nằm bên phải) ===
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      context.read<MusicCubit>().ControlRepeat();
                                    },
                                    icon: Icon(
                                      state.isRepeat ? Icons.repeat_one : Icons.repeat,
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
  void _showCommentBottomSheet(BuildContext context, Song currentSong) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Để bọc bo góc bên trong Widget
      builder: (context) {
        // Gọi riêng 1 file/widget quản lý trạng thái
        return CommentBottomSheetWidget(song: currentSong); 
      },
    );
  }
}
// ==========================================
// WIDGET BÌNH LUẬN CHUẨN CROSS-PLATFORM
// ==========================================
class CommentBottomSheetWidget extends StatefulWidget {
  final Song song;
  const CommentBottomSheetWidget({super.key, required this.song});

  @override
  State<CommentBottomSheetWidget> createState() => _CommentBottomSheetWidgetState();
}

class _CommentBottomSheetWidgetState extends State<CommentBottomSheetWidget> {
  final TextEditingController _commentController = TextEditingController();
  final CommentRepository _commentRepo = CommentRepository();
  late Stream<List<Comment>> _commentStream; // Biến cache Stream

  @override
  void initState() {
    super.initState();
    // QUAN TRỌNG NHẤT: Khởi tạo Stream đúng 1 lần khi mở khung
    _commentStream = _commentRepo.getCommentsBySong(widget.song.title);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.read<ThemeCubit>().state;
    final bgColor = isDark ? const Color(0xFF131E3A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Bình luận - ${widget.song.title}",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const Divider(),
          
          // DÙNG LẠI STREAMBUILDER NHƯNG TRUYỀN BIẾN ĐÃ CACHE VÀO
          Expanded(
            child: StreamBuilder<List<Comment>>(
              stream: _commentStream, 
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Lỗi: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "Chưa có bình luận nào. Hãy là người đầu tiên!",
                      style: TextStyle(color: textColor.withOpacity(0.5)),
                    ),
                  );
                }

                final comments = snapshot.data!;
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final cmt = comments[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          cmt.userName.isNotEmpty ? cmt.userName[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(cmt.userName, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(cmt.content, style: TextStyle(color: textColor.withOpacity(0.8))),
                    );
                  },
                );
              },
            ),
          ),
          
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: "Nhập bình luận...",
                    hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  final text = _commentController.text.trim();
                  if (text.isEmpty) return;

                  _commentController.clear();
                  final userName = user?.displayName ?? user?.email?.split('@')[0] ?? 'Anonymous';

                  final newComment = Comment(
                    id: '', 
                    songId: widget.song.title,
                    userId: user?.uid ?? 'unknown',
                    userName: userName,
                    content: text,
                    rating: 5.0,
                    createdAt: DateTime.now(), 
                  );

                  try {
                    await _commentRepo.addComment(newComment);
                  } catch (e) {
                    debugPrint('Lỗi gửi bình luận: $e');
                  }
                },
                icon: const Icon(Icons.send, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}