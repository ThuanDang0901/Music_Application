import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/module/domain/entities/song.dart';
import 'package:flutter_application_1/module/presentation/cubit/music_cubit.dart';
import 'package:flutter_application_1/module/presentation/cubit/music_state.dart';
import 'package:flutter_application_1/module/presentation/cubit/search_cubit.dart';
import 'package:flutter_application_1/module/presentation/cubit/search_state.dart';
import 'package:flutter_application_1/module/presentation/cubit/theme_cubit.dart';
import 'package:flutter_application_1/module/presentation/pages/detail_music.dart';
import 'package:flutter_application_1/module/presentation/widget/mini_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  final List<String> _popularSuggestions = [
    'JekK',
    'lofi',
    'pop',
    'acoustic',
    'chill',
    'relax',
    'hiphop'
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Request focus on page load for a smooth UX
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<SearchCubit>().search(_searchController.text);
      }
    });
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );
    _focusNode.unfocus();
    context.read<SearchCubit>().search(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final bgColor = isDark ? const Color(0xFF091227) : const Color(0xFFEAF0FF);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white60 : Colors.black54;
    final accentColor = const Color(0xFF6C5CE7);
    final cardBgColor = isDark ? const Color(0xFF131E3A) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: isDark ? 0.15 : 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        style: TextStyle(color: textColor, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm bài hát, nghệ sĩ...',
                          hintStyle: TextStyle(color: subTextColor, fontSize: 15),
                          prefixIcon: Icon(Icons.search, color: accentColor),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    context.read<SearchCubit>().clearSearch();
                                  },
                                  child: Icon(Icons.close_rounded, color: textColor),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state is SearchInitial) {
                    return _buildInitialState(textColor, subTextColor, accentColor, cardBgColor);
                  } else if (state is SearchLoading) {
                    return _buildLoadingState(accentColor);
                  } else if (state is SearchError) {
                    return _buildErrorState(state.message, textColor, accentColor);
                  } else if (state is SearchLoaded) {
                    return _buildResultsList(state.results, textColor, subTextColor, accentColor, cardBgColor);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            // Bottom Mini Player
            const MiniPlayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState(Color textColor, Color subTextColor, Color accentColor, Color cardBg) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gợi ý tìm kiếm',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _popularSuggestions.map((suggestion) {
              return GestureDetector(
                onTap: () => _onSuggestionTap(suggestion),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    suggestion,
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 48),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.music_note_rounded,
                  size: 80,
                  color: accentColor.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Khám phá những giai điệu yêu thích',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLoadingState(Color accentColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 45,
            height: 45,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Đang tìm kiếm...',
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, Color textColor, Color accentColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent.withValues(alpha: 0.8)),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<SearchCubit>().search(_searchController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(List<Song> songs, Color textColor, Color subTextColor, Color accentColor, Color cardBg) {
    if (songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 72,
              color: textColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy bài hát nào',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy thử tìm kiếm với từ khóa khác',
              style: TextStyle(
                color: subTextColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return BlocBuilder<MusicCubit, MusicState>(
      builder: (context, musicState) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            final isCurrent = musicState is MusicLoaded && musicState.currentSong?.audioUrl == song.audioUrl;
            final isPlaying = isCurrent && musicState.isPlaying;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: isCurrent
                    ? Border.all(color: accentColor.withValues(alpha: 0.5), width: 1.5)
                    : Border.all(color: Colors.transparent),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    song.imageUrl,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 52,
                      height: 52,
                      color: Colors.grey.withValues(alpha: 0.2),
                      child: Icon(Icons.music_note, color: accentColor),
                    ),
                  ),
                ),
                title: Text(
                  song.title,
                  style: TextStyle(
                    color: isCurrent ? accentColor : textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    song.artist,
                    style: TextStyle(
                      color: isCurrent ? accentColor.withValues(alpha: 0.7) : subTextColor,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_filled_rounded,
                    color: accentColor,
                    size: 36,
                  ),
                  onPressed: () {
                    if (isCurrent) {
                      context.read<MusicCubit>().PauseOrResume();
                    } else {
                      context.read<MusicCubit>().playMusic(song);
                    }
                  },
                ),
                onTap: () {
                  context.read<MusicCubit>().playMusic(song);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailMusic(
                        playlist: songs,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
