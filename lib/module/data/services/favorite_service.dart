import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/module/domain/entities/song.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy danh sách yêu thích theo UID của user
  Future<List<Song>> getFavorites(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();

    return snapshot.docs.map((doc) => Song.fromMap(doc.data())).toList();
  }

  // Thêm bài hát vào danh sách yêu thích
  Future<void> addFavorite(String userId, Song song) async {
    final docId = song.audioUrl.hashCode.toString();
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(docId)
        .set(song.toMap());
  }

  // Xóa bài hát khỏi danh sách yêu thích
  Future<void> removeFavorite(String userId, String audioUrl) async {
    final docId = audioUrl.hashCode.toString();
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(docId)
        .delete();
  }
}
