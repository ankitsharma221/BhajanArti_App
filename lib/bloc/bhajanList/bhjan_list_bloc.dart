import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_events.dart';
import 'package:bhajan_arti/bloc/bhajanList/bhjan_list_state.dart';

class BhajanListBloc extends Bloc<BhajanListEvent, BhajanListState> {
  List<Map<String, dynamic>> _globalFavorites = [];
  String _lastFetchedUrl = '';

  BhajanListBloc() : super(BhajanListInitial()) {
    on<FetchBhajans>(_fetchBhajans);
    on<ToggleFavorite>(_toggleFavorite);
    on<LoadFavorites>(_loadFavorites);

    // Trigger LoadFavorites when the bloc is created
    add(LoadFavorites());
  }

  Future<void> _fetchBhajans(
    FetchBhajans event,
    Emitter<BhajanListState> emit,
  ) async {
    // Only fetch if it's a new URL or we don't have data yet
    if (event.apiUrl != _lastFetchedUrl || state is! BhajanListLoaded) {
      emit(BhajanListLoading());
      try {
        final response = await http.get(Uri.parse(event.apiUrl));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as List<dynamic>;
          final updatedData = data.map((bhajan) {
            return {
              ...bhajan,
              'isFavorite': _globalFavorites.any((fav) =>
                  fav['title'] == bhajan['title'] &&
                  fav['lyrics'].join() == bhajan['lyrics'].join()),
            };
          }).toList();
          _lastFetchedUrl = event.apiUrl;
          emit(BhajanListLoaded(updatedData, favorites: _globalFavorites));
        } else {
          emit(BhajanListError(
              'Failed to fetch Bhajans: ${response.statusCode}'));
        }
      } catch (e) {
        emit(BhajanListError('Failed to fetch Bhajans: $e'));
      }
    }
  }

  Future<void> _toggleFavorite(
    ToggleFavorite event,
    Emitter<BhajanListState> emit,
  ) async {
    if (state is BhajanListLoaded) {
      final currentState = state as BhajanListLoaded;
      final isFavorite = _globalFavorites.any((fav) =>
          fav['title'] == event.title &&
          fav['lyrics'].join() == event.lyrics.join());

      if (isFavorite) {
        _globalFavorites.removeWhere((fav) =>
            fav['title'] == event.title &&
            fav['lyrics'].join() == event.lyrics.join());
      } else {
        _globalFavorites.add({
          'title': event.title,
          'lyrics': event.lyrics,
        });
      }

      final List<dynamic> updatedData = currentState.data.map((bhajan) {
        if (bhajan['title'] == event.title) {
          return {
            ...bhajan,
            'isFavorite': !isFavorite,
          };
        }
        return bhajan;
      }).toList();

      emit(BhajanListLoaded(updatedData, favorites: _globalFavorites));
      await _updateSharedPreferences(_globalFavorites);
    }
  }

  Future<void> _loadFavorites(
    LoadFavorites event,
    Emitter<BhajanListState> emit,
  ) async {
    emit(BhajanListLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      _globalFavorites = prefs
              .getStringList('favorite_bhajans')
              ?.map((item) => Map<String, dynamic>.from(jsonDecode(item)))
              .toList() ??
          [];
      if (state is BhajanListLoaded) {
        final currentState = state as BhajanListLoaded;
        final updatedData = currentState.data.map((bhajan) {
          return {
            ...bhajan,
            'isFavorite': _globalFavorites.any((fav) =>
                fav['title'] == bhajan['title'] &&
                fav['lyrics'].join() == bhajan['lyrics'].join()),
          };
        }).toList();
        emit(BhajanListLoaded(updatedData, favorites: _globalFavorites));
      } else {
        // If we don't have data yet, we should fetch it
        if (_lastFetchedUrl.isNotEmpty) {
          add(FetchBhajans(_lastFetchedUrl));
        } else {
          emit(BhajanListLoaded([], favorites: _globalFavorites));
        }
      }
    } catch (e) {
      emit(BhajanListError('Failed to load favorites: $e'));
    }
  }

  Future<void> _updateSharedPreferences(
      List<Map<String, dynamic>> favoriteBhajans) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favorite_bhajans',
      favoriteBhajans.map((item) => jsonEncode(item)).toList(),
    );
  }
}
