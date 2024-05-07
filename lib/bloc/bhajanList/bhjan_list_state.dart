import 'package:equatable/equatable.dart';

abstract class BhajanListEvent extends Equatable {
  const BhajanListEvent();

  @override
  List<Object> get props => [];
}

class FetchBhajans extends BhajanListEvent {
  final String apiUrl;

  const FetchBhajans(this.apiUrl);

  @override
  List<Object> get props => [apiUrl];
}

abstract class BhajanListState extends Equatable {
  const BhajanListState();

  @override
  List<Object> get props => [];
}

class BhajanListInitial extends BhajanListState {}

class BhajanListLoading extends BhajanListState {}

class BhajanListLoaded extends BhajanListState {
  final List<dynamic> data;

  const BhajanListLoaded(this.data);

  @override
  List<Object> get props => [data];
}

class BhajanListError extends BhajanListState {
  final String message;

  const BhajanListError(this.message);

  @override
  List<Object> get props => [message];
}
