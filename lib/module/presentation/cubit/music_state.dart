import 'package:flutter_application_1/module/domain/entities/song.dart';

abstract class MusicState {}

class MusicInitial extends MusicState {}

class MusicLoading extends MusicState {}

class MusicLoaded extends MusicState {
  final List<Song> recommendedSongs;
  final List<Song> playlistSongs;
  // các trường mới cho trình phát nhạc
  final Song? currentSong;
  final bool isPlaying;
  final Duration currentPosition;
  final Duration totalDuration;
  final bool isRepeat;
  final List<Song> favoriteSongs;
  final double volume;

  MusicLoaded({
    required this.recommendedSongs,
    required this.playlistSongs,
    this.currentSong,
    this.isPlaying = false,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.isRepeat = false,
    this.favoriteSongs = const [],
    this.volume = 1.0,
  });
  MusicLoaded copyWith({
    List<Song>? recommendedSongs,
    List<Song>? playlistSongs,
    Song? currentSong,
    bool? isPlaying,
    Duration? currentPosition,
    Duration? totalDuration,
    bool? isRepeat,
    List<Song>? favoriteSongs,
    double? volume,
  }) {
    return MusicLoaded(
      recommendedSongs: recommendedSongs ?? this.recommendedSongs,
      playlistSongs: playlistSongs ?? this.playlistSongs,
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      isRepeat: isRepeat ?? this.isRepeat,
      favoriteSongs: favoriteSongs ?? this.favoriteSongs,
      volume: volume ?? this.volume,
    );
  }
}

class MusicError extends MusicState {
  final String message;
  MusicError(this.message);
}
