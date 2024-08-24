import 'package:equatable/equatable.dart';

abstract class BhajanListState extends Equatable {
  const BhajanListState();

  @override
  List<Object> get props => [];
}

class BhajanListInitial extends BhajanListState {}

class BhajanListLoading extends BhajanListState {}

class BhajanListLoaded extends BhajanListState {
  final List<dynamic> data;
  final List<Map<String, dynamic>> favorites;

  const BhajanListLoaded(this.data, {required this.favorites});

  @override
  List<Object> get props => [data, favorites];
}

class BhajanListError extends BhajanListState {
  final String message;

  const BhajanListError(this.message);

  @override
  List<Object> get props => [message];
}
