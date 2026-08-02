import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String songId; // ID hoặc tên bài hát
  final String userId;
  final String userName; // Lưu kèm tên để đỡ phải query lại user
  final String content;
  final double rating;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.songId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.rating,
    required this.createdAt,
  });

  // Chuyển từ dữ liệu Firebase thành Object của App
  factory Comment.fromMap(String id, Map<String, dynamic> map) {
    return Comment(
      id: id,
      songId: map['songId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      content: map['content'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Chuyển Object của App thành dữ liệu đẩy lên Firebase
  Map<String, dynamic> toMap() {
    return {
      'songId': songId,
      'userId': userId,
      'userName': userName,
      'content': content,
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(), // Để Firebase tự lấy giờ server
    };
  }
}