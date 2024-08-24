import 'package:equatable/equatable.dart';

abstract class BhajanListEvent extends Equatable {
  const BhajanListEvent();
  @override
  List<Object?> get props => [];
}

class FetchBhajans extends BhajanListEvent {
  final String apiUrl;
  FetchBhajans(this.apiUrl);
  @override
  List<Object?> get props => [apiUrl];
}

class ToggleFavorite extends BhajanListEvent {
  final String title;
  final List<String> lyrics;
  const ToggleFavorite(this.title, this.lyrics);

  @override
  List<Object?> get props => [title, lyrics];
}

class LoadFavorites extends BhajanListEvent {}
