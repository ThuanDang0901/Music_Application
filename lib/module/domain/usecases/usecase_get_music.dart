import 'package:flutter_application_1/module/domain/entities/album.dart';
import 'package:flutter_application_1/module/domain/entities/song.dart';
import 'package:flutter_application_1/module/domain/repositories/music_repo.dart';

class GetMusicUseCase 
{
  final IMusicRepository repository;

  GetMusicUseCase(this.repository);

  Future<List<Song>> executeRecommendeds() => repository.getRecommendedSongs();
  Future<List<Song>> executePlaylist() => repository.getPlaylistSongs();
    Future<List<Album>> executeAlbums() => repository.getAlbums();
  Future<List<Song>> executeAlbumSongs(String albumId) => repository.getAlbumSongs(albumId);
}

