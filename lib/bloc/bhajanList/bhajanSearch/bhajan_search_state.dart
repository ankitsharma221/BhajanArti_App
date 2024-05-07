part of 'bhajan_search_bloc.dart';

enum BhajanSearchStatus { initial, loading, success, failure }

class BhajanSearchState extends Equatable {
  const BhajanSearchState({
    required this.status,
    this.results,
    this.error,
  });

  final BhajanSearchStatus status;
  final List<dynamic>? results;
  final String? error;

  @override
  List<Object?> get props => [status, error];

  BhajanSearchState copyWith({
    BhajanSearchStatus? status,
    String? error,
  }) {
    return BhajanSearchState(
      status: status ?? this.status,
      results: results ?? this.results,
      error: error ?? this.error,
    );
  }
}

class BhajanSearchSuccess extends BhajanSearchState {
  final List<dynamic> results;

  const BhajanSearchSuccess({
    required BhajanSearchStatus status,
    required this.results,
    String? error,
  }) : super(status: status, error: error);

  @override
  List<Object?> get props => [status, results, error];
}
