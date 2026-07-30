
import '../../domain/entities/song.dart';
class TrackModel {
  final String id;
  final String name;
  final String artistName;
  final String audioUrl;
  final String imageUrl;

  TrackModel({
    required this.id,
    required this.name,
    required this.artistName,
    required this.audioUrl,
    required this.imageUrl,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      artistName: json['artist_name'] ?? 'Unknown Artist',
      audioUrl: json['audio'] ?? '',
      imageUrl: json['image'] ?? '',
    );
  }

  // Hàm ánh xạ (Mapper) từ Data Model sang Domain Entity
  Song toEntity() {
    return Song(
      // id: id,
      title: name,
      artist: artistName,
      audioUrl: audioUrl,
      imageUrl: imageUrl,
    );
  }
}