import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/module/domain/entities/comment.dart';

class CommentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Hàm gửi bình luận lên Firebase
  Future<void> addComment(Comment comment) async {
    try {
      await _firestore.collection('comments').add(comment.toMap());
    } catch (e) {
      throw Exception('Lỗi khi thêm bình luận: $e');
    }
  }

  // 2. Hàm lấy danh sách bình luận Realtime (Stream) theo bài hát
  Stream<List<Comment>> getCommentsBySong(String songTitle) {
    return _firestore
        .collection('comments')
        .where('songId', isEqualTo: songTitle) // Lọc theo tên bài hát
        .orderBy('createdAt', descending: true) // Mới nhất lên đầu
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Comment.fromMap(doc.id, doc.data()))
          .toList();
    });
  }
}