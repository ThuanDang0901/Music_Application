import 'package:flutter_application_1/module/domain/entities/song.dart';
import 'package:flutter_application_1/module/domain/repositories/music_repo.dart';

class GetUserFavoritesUseCase {
  final IMusicRepository repository;
  GetUserFavoritesUseCase(this.repository);

  Future<List<Song>> execute(String userId) {
    return repository.getUserFavorites(userId);
  }
}
