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
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Clear search state on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchCubit>().clearSearch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final bgColor = isDark ? const Color(0xFF091227) : const Color(0xFFEAF0FF);
    final cardBgColor = isDark ? const Color(0xFF131E3A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.white60 : Colors.black45;
    final iconColor = isDark ? Colors.white : Colors.black87;
    final accentColor = const Color(0xFF6C5CE7);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Tìm kiếm',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: TextStyle(color: textColor, fontSize: 16),
                  cursorColor: accentColor,
                  onChanged: (query) {
                    context.read<SearchCubit>().search(query);
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm bài hát, ca sĩ, nghệ sĩ...',
                    hintStyle: TextStyle(color: subTextColor),
                    prefixIcon: Icon(Icons.search, color: subTextColor),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: subTextColor),
                            onPressed: () {
                              _searchController.clear();
                              context.read<SearchCubit>().clearSearch();
                              setState(() {});
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 14.0,
                    ),
                  ),
                ),
              ),
            ),
            
            // Search Body
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return Center(
                      child: CircularProgressIndicator(color: accentColor),
                    );
                  } else if (state is SearchError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (state is SearchLoaded) {
                    final results = state.results;
                    if (results.isEmpty) {
                      return _buildEmptyState(
                        context,
                        'Không tìm thấy kết quả phù hợp cho "${state.query}"',
                        isDark,
                        subTextColor,
                      );
                    }
                    return _buildSearchResults(results, textColor, subTextColor, accentColor);
                  }
                  
                  // Initial State - Show suggestions
                  return _buildInitialState(context, isDark, textColor, subTextColor, accentColor);
                },
              ),
            ),

            // Mini Player at bottom
            const MiniPlayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState(
    BuildContext context,
    bool isDark,
    Color textColor,
    Color subTextColor,
    Color accentColor,
  ) {
    final suggestions = ['Imagine Dragons', 'B-Wine', 'SIA', 'ODESZA', 'Lindsey Stirling'];

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
            spacing: 12,
            runSpacing: 12,
            children: suggestions.map((artist) {
              return InkWell(
                onTap: () {
                  _searchController.text = artist;
                  context.read<SearchCubit>().search(artist);
                  setState(() {});
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF131E3A) : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up, size: 16, color: accentColor),
                      const SizedBox(width: 8),
                      Text(
                        artist,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
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
                  'Khám phá âm nhạc yêu thích của bạn',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String message,
    bool isDark,
    Color subTextColor,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 80,
              color: subTextColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: subTextColor,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    List<Song> results,
    Color textColor,
    Color subTextColor,
    Color accentColor,
  ) {
    return BlocBuilder<MusicCubit, MusicState>(
      builder: (context, musicState) {
        Song? playingSong;
        bool isPlaying = false;
        if (musicState is MusicLoaded) {
          playingSong = musicState.currentSong;
          isPlaying = musicState.isPlaying;
        }

        return ListView.builder(
          itemCount: results.length,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemBuilder: (context, index) {
            final song = results[index];
            final isCurrent = playingSong != null &&
                playingSong.title == song.title &&
                playingSong.artist == song.artist;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isCurrent
                    ? accentColor.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                onTap: () {
                  context.read<MusicCubit>().playMusic(song);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailMusic(
                        playlist: results,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    song.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  song.title,
                  style: TextStyle(
                    color: isCurrent ? accentColor : textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  song.artist,
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 13,
                  ),
                ),
                trailing: isCurrent && isPlaying
                    ? Icon(
                        Icons.volume_up,
                        color: accentColor,
                      )
                    : Icon(
                        Icons.play_circle_outline,
                        color: isCurrent ? accentColor : subTextColor,
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
