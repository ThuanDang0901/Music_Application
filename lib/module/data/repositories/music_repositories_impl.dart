import 'package:flutter_application_1/module/data/models/AlbumModel.dart';
import 'package:flutter_application_1/module/domain/entities/album.dart';
import 'package:flutter_application_1/module/domain/entities/song.dart';
import 'package:flutter_application_1/module/domain/repositories/music_repo.dart';
import '../models/track_model.dart';
import '../services/jamendo_api_service.dart';

class MusicRepositoriesImpl implements IMusicRepository {

  final JamendoApiService apiService;
MusicRepositoriesImpl({required this.apiService});
@override
  Future<List<Song>> getRecommendedSongs() async {
    
    final List<TrackModel> trackModels = await apiService.fetchPopularTracks(limit: 10);
    
    
    return trackModels.map((model) => model.toEntity()).toList();
  }
@override
  Future<List<Song>> getPlaylistSongs() async {
   
    final List<TrackModel> trackModels = await apiService.searchTracks('lofi', limit: 15);
    
    return trackModels.map((model) => model.toEntity()).toList();
  }
  @override
  Future<List<Album>> getAlbums() async {
    final List<AlbumModel> albumModels = await apiService.fetchAlbums(limit: 15);
    return albumModels.map((model) => model.toEntity()).toList();
  }
  @override
  Future<List<Song>> getAlbumSongs(String albumId) async {
    final List<TrackModel> trackModels = await apiService.fetchTracksByAlbumId(albumId);
    return trackModels.map((model) => model.toEntity()).toList();
  }



  // @override
  // Future<List<Song>> getRecommendedSongs() async {
  //   await Future.delayed(const Duration(seconds: 1));
  //   return [
  //     Song(
  //       title: 'DATLE',
  //       artist: 'B-Wine',
  //       imageUrl: 'assets/img/1.jpg',
  //       audioUrl: 'audio/b-wine.mp3',
  //     ),
  //     Song(
  //       title: 'Moment Apart',
  //       artist: 'ODESZA',
  //       imageUrl: 'assets/img/2.jpg',
  //       audioUrl: 'audio/Drt.mp3',
  //     ),
  //     Song(
  //       title: 'Something Wild',
  //       artist: 'LINDSEY STIRLING',
  //       imageUrl: 'assets/img/3.jpg',
  //       audioUrl: 'audio/Eminmes.mp3',
  //     ),
  //     Song(
  //       title: 'Alive',
  //       artist: 'SIA',
  //       imageUrl: 'assets/img/4.jpg',
  //       audioUrl: 'audio/lowg.mp3',
  //     ),
  //   ];
  // }

  // @override
  // Future<List<Song>> getPlaylistSongs() async {
  //   await Future.delayed(const Duration(seconds: 1));
  //   return [
  //     Song(
  //       title: 'Believer',
  //       artist: 'IMAGINE DRAGONS',
  //       imageUrl: 'assets/img/5.jpg',
  //       audioUrl: '',
  //     ),
  //     Song(
  //       title: 'Shortwave',
  //       artist: 'RYAN TAUBERT',
  //       imageUrl: 'assets/img/6.jpg',
  //       audioUrl: 'audio/tw.mp3',
  //     ),
  //     Song(
  //       title: 'Natural',
  //       artist: 'IMAGINE DRAGONS',
  //       imageUrl: 'assets/img/7.jpg',
  //       audioUrl: 'Gỗ.mp3',
  //     ),
  //     Song(
  //       title: 'Radioactive',
  //       artist: 'IMAGINE DRAGONS',
  //       imageUrl: 'assets/img/8.jpg',
  //       audioUrl: 'xxxtentation.mp3',
  //     ),
  //   ];
  // }
}
