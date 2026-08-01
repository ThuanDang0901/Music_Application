import 'package:flutter_application_1/module/domain/entities/song.dart';
import 'package:flutter_application_1/module/domain/repositories/music_repo.dart';

class AddFavoriteSongUseCase {
  final IMusicRepository repository;
  AddFavoriteSongUseCase(this.repository);

  Future<void> execute(String userId, Song song) {
    return repository.addFavoriteSong(userId, song);
  }
}
