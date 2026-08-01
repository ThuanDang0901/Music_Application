import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_application_1/module/presentation/cubit/auth_cubit.dart';
import 'package:flutter_application_1/module/presentation/cubit/auth_state.dart';
import 'package:flutter_application_1/module/presentation/cubit/music_cubit.dart';
import 'package:flutter_application_1/module/presentation/cubit/music_state.dart';
import 'package:flutter_application_1/module/presentation/cubit/theme_cubit.dart';
import 'package:flutter_application_1/module/presentation/pages/detail_music.dart';
import 'package:flutter_application_1/module/presentation/pages/list_favorite_song.dart';
import 'package:flutter_application_1/module/presentation/pages/login_page.dart';
import 'package:flutter_application_1/module/presentation/widget/mini_player.dart';
import 'package:flutter_application_1/module/presentation/widget/toast_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/module/presentation/cubit/search_cubit.dart';
import 'package:flutter_application_1/module/presentation/pages/search_page.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_search_music.dart';
import 'package:flutter_application_1/module/data/repositories/music_repositories_impl.dart';
import 'package:flutter_application_1/module/data/services/jamendo_api_service.dart';

class HomeMusic extends StatelessWidget {
  const HomeMusic({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = context.read<ThemeCubit>().state;
        final bg = isDark ? const Color(0xFF1A1A2E) : Colors.white;
        final text = isDark ? Colors.white : Colors.black87;
        return AlertDialog(
          backgroundColor: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Đăng xuất',
            style: TextStyle(color: text, fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Bạn có chắc muốn đăng xuất khỏi tài khoản không?',
            style: TextStyle(color: text.withValues(alpha: 0.75), fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: text.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Đăng xuất'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      context.read<AuthCubit>().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final authState = context.watch<AuthCubit>().state;

    final bgColor = isDark ? const Color(0xFF091227) : const Color(0xFFEAF0FF);
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.white60 : Colors.black45;
    final iconColor = isDark ? Colors.white : Colors.black87;
    final accentColor = const Color(0xFF6C5CE7);

    final user = authState.user;
    final displayName =
        user?.displayName ?? user?.email ?? user?.phoneNumber ?? 'Người dùng';
    final userEmail = user?.email ?? user?.phoneNumber ?? '';
    final photoUrl = user?.photoUrl;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.failure &&
            state.action == AuthAction.signOut) {
          ToastHelper.showError(
            context: context,
            message: state.message ?? 'Đăng xuất thất bại. Vui lòng thử lại.',
          );
          context.read<AuthCubit>().consumeTransientState();
        }

        if (state.status == AuthStatus.unauthenticated &&
            state.action == AuthAction.signOut) {
          ToastHelper.showSuccess(
            context: context,
            message: 'Đã đăng xuất thành công.',
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
      drawer: Drawer(
        backgroundColor: bgColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                        isDark
                            ? Icons.wb_sunny_outlined
                            : Icons.nightlight_round,
                        size: 28,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? accentColor.withValues(alpha: 0.1)
                        : accentColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.25),
                    ),
                  ),
                  
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor.withValues(alpha: 0.2),
                          
                          image: photoUrl != null && photoUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(photoUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                              
                        ),
                        
                        child: photoUrl == null || photoUrl.isEmpty
                            ? Icon(
                                Icons.person_rounded,
                                color: accentColor,
                                size: 30,
                              )
                            : null,
                            
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (userEmail.isNotEmpty)
                              Text(
                                userEmail,
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                InkWell(
                  onTap: () {
                    ToastHelper.showInfo(
                      context: context,
                      message: 'Trang Profile đang được phát triển.',
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 6),
                    child: Row(
                      children: [
                        Icon(Icons.person_outline,
                            color: iconColor, size: 28),
                        const SizedBox(width: 16),
                        Text(
                          'Hồ sơ cá nhân',
                          style: TextStyle(color: textColor, fontSize: 17),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ListFavoriteSong(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 6),
                    child: Row(
                      children: [
                        Icon(Icons.favorite_border_outlined,
                            color: iconColor, size: 28),
                        const SizedBox(width: 16),
                        Text(
                          'Bài hát đã thích',
                          style: TextStyle(color: textColor, fontSize: 17),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                const Divider(),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => _handleLogout(context),
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 6),
                    child: Row(
                      children: const [
                        Icon(Icons.logout_rounded,
                            color: Color(0xFFE74C3C), size: 28),
                        SizedBox(width: 16),
                        Text(
                          'Đăng xuất',
                          style: TextStyle(
                              color: Color(0xFFE74C3C),
                              fontSize: 17,
                              fontWeight: FontWeight.w600),
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
                                 GestureDetector(
                                   onTap: () {
                                     Navigator.push(
                                       context,
                                       MaterialPageRoute(
                                         builder: (context) => BlocProvider(
                                           create: (context) => SearchCubit(
                                             searchMusicUseCase: SearchMusicUseCase(
                                               MusicRepositoriesImpl(apiService: JamendoApiService()),
                                             ),
                                           ),
                                           child: const SearchPage(),
                                         ),
                                       ),
                                     );
                                   },
                                   child: Icon(Icons.search, color: iconColor, size: 28),
                                 ),
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
                                            // image: AssetImage(song.imageUrl),
                                            image: NetworkImage(song.imageUrl),
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
                           return GestureDetector(
                                onTap: () {
                                  context.read<MusicCubit>().playMusic(song);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailMusic(
                                        playlist: state.playlistSongs,
                                        initialIndex: index,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
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
                                            image: NetworkImage(song.imageUrl),
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
    ));
  }
}
