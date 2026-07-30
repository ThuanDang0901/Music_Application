import 'package:flutter_application_1/module/domain/entities/song.dart';
import 'package:flutter_application_1/module/domain/repositories/music_repo.dart';

class SearchSongsUseCase {
  final IMusicRepository repository;

  SearchSongsUseCase(this.repository);

  Future<List<Song>> execute(String query) async {
    return repository.searchSongs(query);
  }
}
