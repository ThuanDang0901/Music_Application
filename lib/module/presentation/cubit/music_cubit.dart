import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/module/domain/entities/song.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_add_favorite_song.dart';
import 'package:flutter_application_1/module/domain/entities/album.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_get_music.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_get_user_favorites.dart';
import 'package:flutter_application_1/module/domain/usecases/usecase_remove_favorite_song.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'music_state.dart';

class MusicCubit extends Cubit<MusicState> {
  final GetMusicUseCase getMusicUseCase;
  final GetUserFavoritesUseCase getUserFavoritesUseCase;
  final AddFavoriteSongUseCase addFavoriteSongUseCase;
  final RemoveFavoriteSongUseCase removeFavoriteSongUseCase;
  final AudioPlayer _audioPlayer = AudioPlayer();

  MusicCubit({
    required this.getMusicUseCase,
    required this.getUserFavoritesUseCase,
    required this.addFavoriteSongUseCase,
    required this.removeFavoriteSongUseCase,
  }) : super(MusicInitial()) {
    _audioPlayer.onPositionChanged.listen((pos) {
      if (state is MusicLoaded) {
        emit((state as MusicLoaded).copyWith(currentPosition: pos));
      }
    });
    _audioPlayer.onDurationChanged.listen((dur) {
      if (state is MusicLoaded) {
        emit((state as MusicLoaded).copyWith(totalDuration: dur));
      }
    });
    _audioPlayer.onPlayerComplete.listen((event) async {
      if (state is MusicLoaded) {
        final currentState = state as MusicLoaded;
        if (currentState.isRepeat) {
          if (currentState.currentSong != null) {
            await playMusic(currentState.currentSong!);
          }
        } else {
          playNext();
        }
      }
    });
  }

  // Tải dữ liệu bài hát cùng với nhạc yêu thích của User
  Future<void> loadMusicData({String? userId}) async {
     List<Song> recommended = [];
    List<Song> playlist = [];
    List<Album> albums = [];
     if (recommended.isEmpty && playlist.isEmpty) {
      // Nếu CẢ HAI đều thất bại, lúc này mới báo lỗi ra màn hình
      emit(MusicError('Máy chủ đang quá tải hoặc lỗi mạng. Vui lòng thử lại sau!'));
     }
    emit(MusicLoading());
    try {
      final recommended = await getMusicUseCase.executeRecommendeds();
       await Future.delayed(const Duration(milliseconds: 500));
      // final playlist = await getMusicUseCase.executePlaylist();

      List<Song> favorites = [];
      if (userId != null && userId.isNotEmpty) {
        favorites = await getUserFavoritesUseCase.execute(userId);
      }
       try {
      albums = await getMusicUseCase.executeAlbums();
    } catch (e) {
      debugPrint('=== LỖI TẢI PLAYLIST: $e ===');
      // Không văng lỗi toàn cục, cứ để list rỗng
    }


      emit(
        MusicLoaded(
         recommendedSongs: recommended, 
         albums: albums,
         currentQueue: recommended,
          favoriteSongs: favorites,
        ),
      );
    } catch (e) {
      debugPrint('=== LỖI LOAD NHẠC: $e ===');
      emit(MusicError('Lỗi: $e'));
    }
  }
  Future<List<Song>> getSongsForAlbum(String albumId) async {
    try {
      return await getMusicUseCase.executeAlbumSongs(albumId);
    } catch (e) {
      debugPrint('Lỗi tải bài hát của album: $e');
      return []; // Trả về list rỗng nếu lỗi
    }
  }

  Future<void> ControlFavoriteSong(Song song, {String? userId}) async {
    if (state is MusicLoaded) {
      final currentState = state as MusicLoaded;
      final List<Song> updatedFavorites = List.from(currentState.favoriteSongs);
      final isExist = updatedFavorites.any((s) => s.audioUrl == song.audioUrl);

      if (isExist) {
        updatedFavorites.removeWhere((s) => s.audioUrl == song.audioUrl);
        emit(currentState.copyWith(favoriteSongs: updatedFavorites));

        if (userId != null && userId.isNotEmpty) {
          await removeFavoriteSongUseCase.execute(userId, song.audioUrl);
        }
      } else {
        updatedFavorites.add(song);
        emit(currentState.copyWith(favoriteSongs: updatedFavorites));

        if (userId != null && userId.isNotEmpty) {
          await addFavoriteSongUseCase.execute(userId, song);
        }
      }
    }
  }

  Future<void> playMusic(Song song ,{List<Song>? queue}) async {
    if (state is MusicLoaded) {
      
      final currentState = state as MusicLoaded;
      // Kiểm tra xem audioUrl có phải là link mạng (bắt đầu bằng http/https) hay không.
      // Nếu có -> Phát qua UrlSource (nhạc Jamendo)
      // Nếu không (HOẶC) -> Phát qua AssetSource (nhạc mock data)
      final source = song.audioUrl.startsWith('http') 
          ? UrlSource(song.audioUrl) 
          : AssetSource(song.audioUrl);

      await _audioPlayer.play(source);
      emit((state as MusicLoaded).copyWith(currentSong: song, isPlaying: true,currentQueue: queue ?? currentState.currentQueue,));
    }
  }

  Future<void> PauseOrResume() async {
    if (state is MusicLoaded) {
      final currentState = state as MusicLoaded;
      if (currentState.isPlaying) {
        await _audioPlayer.pause();
        emit(currentState.copyWith(isPlaying: false));
      } else if (currentState.currentSong != null) {
        await _audioPlayer.resume();
        emit(currentState.copyWith(isPlaying: true));
      }
    }
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> playNext() async {
    if (state is MusicLoaded) {
      final currentState = state as MusicLoaded;
      if (currentState.currentSong == null) return;

      final currentUrl = currentState.currentSong!.audioUrl;
       List<Song> activePlaylist = currentState.currentQueue;
    if (activePlaylist.isEmpty) return;
      int currentIndex = activePlaylist.indexWhere(
        (song) => song.audioUrl == currentUrl,
      );

      if (currentIndex == -1) {
        activePlaylist = currentState.recommendedSongs;
        currentIndex = activePlaylist.indexWhere(
          (song) => song.audioUrl == currentUrl,
        );
      }
      if (currentIndex != -1 && activePlaylist.isNotEmpty) {
        int nextIndex = currentIndex + 1;
        if (nextIndex >= activePlaylist.length) {
          nextIndex = 0; // Quay lại bài đầu
        }
        await playMusic(activePlaylist[nextIndex]);
      }
    }
  }

  Future<void> playPrevious() async {
    if (state is MusicLoaded) {
      final currentState = state as MusicLoaded;
      if (currentState.currentSong == null) return;

      final currentUrl = currentState.currentSong!.audioUrl;

       List<Song> activePlaylist = currentState.currentQueue;
      if (activePlaylist.isEmpty) return;
      int currentIndex = activePlaylist.indexWhere(
        (song) => song.audioUrl == currentUrl,
      );

      if (currentIndex == -1) {
        activePlaylist = currentState.recommendedSongs;
        currentIndex = activePlaylist.indexWhere(
          (song) => song.audioUrl == currentUrl,
        );
      }

      if (currentIndex != -1 && activePlaylist.isNotEmpty) {
        if (currentState.isPlaying &&
            currentState.currentPosition.inSeconds > 3) {
          await seek(Duration.zero);
          return;
        }

        int prevIndex = currentIndex - 1;
        if (prevIndex < 0) {
          prevIndex = activePlaylist.length - 1;
        }
        await playMusic(activePlaylist[prevIndex]);
      }
    }
  }

  void ControlRepeat() {
    if (state is MusicLoaded) {
      final currentState = state as MusicLoaded;
      emit(currentState.copyWith(isRepeat: !currentState.isRepeat));
    }
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
