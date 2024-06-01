import 'package:equatable/equatable.dart';

abstract class BhajanListState extends Equatable {
  const BhajanListState();

  @override
  List<Object?> get props => [];
}

class BhajanListInitial extends BhajanListState {}

class BhajanListLoading extends BhajanListState {}

class BhajanListLoaded extends BhajanListState {
  final List<dynamic> data;

  const BhajanListLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class BhajanListError extends BhajanListState {
  final String errorMessage;

  const BhajanListError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
