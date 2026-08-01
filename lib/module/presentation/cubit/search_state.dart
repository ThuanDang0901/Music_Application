import 'package:flutter_application_1/module/domain/entities/song.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Song> results;
  final String query;

  SearchLoaded({required this.results, required this.query});
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}
