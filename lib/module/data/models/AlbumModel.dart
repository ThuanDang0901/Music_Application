import '../../domain/entities/album.dart';

class AlbumModel {
  final String id;
  final String name;
  final String artistName;
  final String imageUrl;

  AlbumModel({
    required this.id,
    required this.name,
    required this.artistName,
    required this.imageUrl,
  });

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Album',
      artistName: json['artist_name'] ?? 'Unknown Artist',
      imageUrl: json['image'] ?? '',
    );
  }

  Album toEntity() {
    return Album(
      id: id,
      name: name,
      artistName: artistName,
      imageUrl: imageUrl,
    );
  }
}