import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_events.dart';
import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_state.dart';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BhajanListBloc extends Bloc<BhajanListEvent, BhajanListState> {
  BhajanListBloc() : super(BhajanListInitial()) {
    on<FetchBhajans>(_fetchBhajans);
  }

  Future<void> _fetchBhajans(
    FetchBhajans event,
    Emitter<BhajanListState> emit,
  ) async {
    emit(BhajanListLoading());
    try {
      final response = await http.get(Uri.parse(event.apiUrl));
      final data = jsonDecode(response.body) as List<dynamic>;
      emit(BhajanListLoaded(data));
    } catch (e) {
      emit(BhajanListError('Failed to fetch Bhajans: $e'));
    }
  }
}
