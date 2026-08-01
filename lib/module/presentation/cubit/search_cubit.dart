import 'package:flutter_application_1/module/domain/usecases/usecase_search_music.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchMusicUseCase searchMusicUseCase;

  SearchCubit({required this.searchMusicUseCase}) : super(SearchInitial());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());
    try {
      final results = await searchMusicUseCase.execute(query);
      emit(SearchLoaded(results: results, query: query));
    } catch (e) {
      emit(SearchError('Lỗi tìm kiếm: $e'));
    }
  }

  void clearSearch() {
    emit(SearchInitial());
  }
}
