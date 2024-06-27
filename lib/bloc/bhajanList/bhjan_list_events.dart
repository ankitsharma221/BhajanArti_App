import 'package:equatable/equatable.dart';

abstract class BhajanListEvent extends Equatable {
  const BhajanListEvent();

  @override
  List<Object?> get props => [];
}

class FetchBhajans extends BhajanListEvent {
  final String apiUrl;

  const FetchBhajans(this.apiUrl);

  @override
  List<Object?> get props => [apiUrl];
}

class ToggleFavorite extends BhajanListEvent {
  final String title;

  const ToggleFavorite(this.title);

  @override
  List<Object?> get props => [title];
}
