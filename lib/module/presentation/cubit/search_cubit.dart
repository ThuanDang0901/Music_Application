import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/module/domain/usecases/search_songs_usecase.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchSongsUseCase searchSongsUseCase;

  SearchCubit({required this.searchSongsUseCase}) : super(SearchInitial());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }
    emit(SearchLoading());
    try {
      final results = await searchSongsUseCase.execute(query);
      emit(SearchLoaded(results: results, query: query));
    } catch (e) {
      emit(SearchError('Lỗi khi tìm kiếm: $e'));
    }
  }

  void clearSearch() {
    emit(SearchInitial());
  }
}
