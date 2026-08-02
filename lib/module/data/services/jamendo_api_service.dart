import 'dart:convert';
import 'package:flutter_application_1/module/data/models/AlbumModel.dart';
import 'package:http/http.dart' as http;
import '../models/track_model.dart';


class JamendoApiService {
  
  static const String clientId = 'd3615367'; 
  static const String baseUrl = 'https://api.jamendo.com/v3.0';

  // Lấy danh sách bài hát phổ biến
  Future<List<TrackModel>> fetchPopularTracks({int limit = 10}) async {
    final url = Uri.parse('$baseUrl/tracks/?client_id=$clientId&format=jsonpretty&limit=$limit&order=popularity_total');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        
        return results.map((json) => TrackModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tracks: $e');
    }
  }
  Future<List<TrackModel>> searchTracks(String query, {int limit = 10}) async {
    final url = Uri.parse(
        '$baseUrl/tracks/?client_id=$clientId&format=json&limit=$limit&search=$query');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Kiểm tra status từ headers của API
        if (data['headers']['status'] == 'success') {
          final List<dynamic> results = data['results'];
          // Map dữ liệu JSON vào TrackModel
          return results.map((json) => TrackModel.fromJson(json)).toList();
        } else {
           throw Exception('API Error: ${data['headers']['error_message']}');
        }
      } else {
        throw Exception('Failed to search tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching tracks: $e');
    }
  }

   Future<List<AlbumModel>> fetchAlbums({int limit = 15}) async {
    final url = Uri.parse(
        '$baseUrl/albums/?client_id=$clientId&format=json&limit=$limit');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['headers']['status'] == 'success') {
          final List<dynamic> results = data['results'];
          return results.map((json) => AlbumModel.fromJson(json)).toList();
        } else {
           throw Exception('API Error: ${data['headers']['error_message']}');
        }
      } else {
        throw Exception('Failed to load albums: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching albums: $e');
    }
  }

  // Hàm lấy danh sách bài hát theo ID Album
  Future<List<TrackModel>> fetchTracksByAlbumId(String albumId) async {
    final url = Uri.parse(
        '$baseUrl/tracks/?client_id=$clientId&format=json&album_id=$albumId');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['headers']['status'] == 'success') {
          final List<dynamic> results = data['results'];
          return results.map((json) => TrackModel.fromJson(json)).toList();
        } else {
          throw Exception('API Error: ${data['headers']['error_message']}');
        }
      } else {
        throw Exception('Failed to load album tracks');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}