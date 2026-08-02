import 'package:flutter_application_1/module/domain/entities/album.dart';
import 'package:flutter_application_1/module/domain/entities/song.dart';

abstract class MusicState {}

class MusicInitial extends MusicState {}

class MusicLoading extends MusicState {}

class MusicLoaded extends MusicState {
  final List<Song> recommendedSongs;
  final List<Album>albums;
  final List<Song> currentQueue;
  // các trường mới cho trình phát nhạc
  final Song? currentSong;
  final bool isPlaying;
  final Duration currentPosition;
  final Duration totalDuration;
  final bool isRepeat;
  final List<Song> favoriteSongs;

  MusicLoaded({
    required this.recommendedSongs,
    required this.albums,
    this.currentQueue = const [],
    this.currentSong,
    this.isPlaying = false,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.isRepeat = false,
    this.favoriteSongs = const [],
  });
  MusicLoaded copyWith({
    List<Song>? recommendedSongs,
    List<Album>? albums,
  List<Song>? currentQueue,
    Song? currentSong,
    bool? isPlaying,
    Duration? currentPosition,
    Duration? totalDuration,
    bool? isRepeat,
    List<Song>? favoriteSongs,
  }) {
    return MusicLoaded(
      recommendedSongs: recommendedSongs ?? this.recommendedSongs,
      albums: albums ?? this.albums,
      currentQueue: currentQueue ?? this.currentQueue,
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      isRepeat: isRepeat ?? this.isRepeat,
      favoriteSongs: favoriteSongs ?? this.favoriteSongs,
    );
  }
}

class MusicError extends MusicState {
  final String message;
  MusicError(this.message);
}
