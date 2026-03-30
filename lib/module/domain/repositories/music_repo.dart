import "package:flutter_application_1/module/domain/entities/song.dart";

abstract class IMusicRepository {
  Future<List<Song>> getRecommendedSongs();
  Future<List<Song>> getPlaylistSongs();
}
