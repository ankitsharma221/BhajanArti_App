import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'bhajan_search_events.dart';
part 'bhajan_search_state.dart';

class BhajanSearchBloc extends Bloc<BhajanSearchEvent, BhajanSearchState> {
  final List<dynamic> data;

  BhajanSearchBloc(this.data)
      : super(const BhajanSearchState(
          status: BhajanSearchStatus.initial,
        )) {
    on<SearchBhajans>((event, emit) async {
      emit(const BhajanSearchState(status: BhajanSearchStatus.loading));
      try {
        List<dynamic> results = data
            .where((bhajan) => bhajan['title']
                .toLowerCase()
                .contains(event.query.toLowerCase()))
            .toList();
        emit(BhajanSearchState(
            status: BhajanSearchStatus.success, results: results));
      } catch (e) {
        emit(BhajanSearchState(
            status: BhajanSearchStatus.failure, error: e.toString()));
      }
    });
  }
}
