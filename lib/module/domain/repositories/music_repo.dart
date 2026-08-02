import "package:flutter_application_1/module/domain/entities/album.dart";
import "package:flutter_application_1/module/domain/entities/song.dart";

abstract class IMusicRepository {
  Future<List<Song>> getRecommendedSongs();
  Future<List<Song>> getPlaylistSongs();
  Future<List<Album>> getAlbums();
  Future<List<Song>> getAlbumSongs(String albumId);
}
