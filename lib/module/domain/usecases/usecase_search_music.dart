import 'package:flutter_application_1/module/domain/entities/song.dart';
import 'package:flutter_application_1/module/domain/repositories/music_repo.dart';

class SearchMusicUseCase {
  final IMusicRepository repository;

  SearchMusicUseCase(this.repository);

  Future<List<Song>> execute(String query) {
    return repository.searchSongs(query);
  }
}
