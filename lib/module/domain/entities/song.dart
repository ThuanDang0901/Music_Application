class Song {
  final String title;
  final String artist;
  final String imageUrl;
  final String audioUrl;

  Song({
    required this.title,
    required this.artist,
    required this.imageUrl,
    required this.audioUrl,
  });
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      audioUrl: map['audioUrl'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song &&
          runtimeType == other.runtimeType &&
          audioUrl == other.audioUrl;

  @override
  int get hashCode => audioUrl.hashCode;
}
