import "package:flutter_application_1/module/domain/entities/album.dart";
import "package:flutter_application_1/module/domain/entities/song.dart";

abstract class IMusicRepository {
  Future<List<Song>> getRecommendedSongs();
  Future<List<Song>> getPlaylistSongs();
  Future<List<Song>> searchSongs(String query);
    Future<List<Album>> getAlbums();
  Future<List<Song>> getAlbumSongs(String albumId);

  // Firestore Favorite methods
  Future<List<Song>> getUserFavorites(String userId);
  Future<void> addFavoriteSong(String userId, Song song);
  Future<void> removeFavoriteSong(String userId, String audioUrl);
}
