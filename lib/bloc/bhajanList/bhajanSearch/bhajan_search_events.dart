part of 'bhajan_search_bloc.dart';

abstract class BhajanSearchEvent extends Equatable {
  const BhajanSearchEvent();

  @override
  List<Object> get props => [];
}

class SearchBhajans extends BhajanSearchEvent {
  final String query;

  const SearchBhajans(this.query);

  @override
  List<Object> get props => [query];
}
