import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_events.dart';
import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_state.dart';

class BhajanListBloc extends Bloc<BhajanListEvent, BhajanListState> {
  BhajanListBloc() : super(BhajanListInitial()) {
    on<FetchBhajans>(_fetchBhajans);
    on<ToggleFavorite>(_toggleFavorite);
  }

  Future<void> _fetchBhajans(
    FetchBhajans event,
    Emitter<BhajanListState> emit,
  ) async {
    emit(BhajanListLoading());
    try {
      final response = await http.get(Uri.parse(event.apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;

        final prefs = await SharedPreferences.getInstance();
        final favoriteTitles = prefs.getStringList('favorite_bhajans') ?? [];

        final updatedData = data.map((bhajan) {
          return {
            ...bhajan,
            'isFavorite': favoriteTitles.contains(bhajan['title']),
          };
        }).toList();

        emit(BhajanListLoaded(updatedData, favorites: favoriteTitles));
      } else {
        emit(
            BhajanListError('Failed to fetch Bhajans: ${response.statusCode}'));
      }
    } catch (e) {
      emit(BhajanListError('Failed to fetch Bhajans: $e'));
    }
  }

  Future<void> _toggleFavorite(
    ToggleFavorite event,
    Emitter<BhajanListState> emit,
  ) async {
    if (state is BhajanListLoaded) {
      final List<dynamic> updatedData =
          (state as BhajanListLoaded).data.map((bhajan) {
        if (bhajan['title'] == event.title) {
          return {
            ...bhajan,
            'isFavorite': !(bhajan['isFavorite'] ?? false),
          };
        }
        return bhajan;
      }).toList();

      emit(BhajanListLoaded(updatedData,
          favorites: _extractFavorites(updatedData)));

      await _updateSharedPreferences(updatedData);
    }
  }

  List<String> _extractFavorites(List<dynamic> data) {
    return data
        .where((bhajan) => bhajan['isFavorite'] == true)
        .map((bhajan) => bhajan['title'] as String)
        .toList();
  }

  Future<void> _updateSharedPreferences(List<dynamic> updatedData) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteTitles = _extractFavorites(updatedData);
    await prefs.setStringList('favorite_bhajans', favoriteTitles);
  }
}
