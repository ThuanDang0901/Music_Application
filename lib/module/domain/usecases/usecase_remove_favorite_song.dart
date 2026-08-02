import 'package:flutter_application_1/module/domain/repositories/music_repo.dart';

class RemoveFavoriteSongUseCase {
  final IMusicRepository repository;
  RemoveFavoriteSongUseCase(this.repository);

  Future<void> execute(String userId, String audioUrl) {
    return repository.removeFavoriteSong(userId, audioUrl);
  }
}
  