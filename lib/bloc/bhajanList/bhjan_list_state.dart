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
  final List<String> favorites; // Add favorites list

  BhajanListLoaded(this.data, {required this.favorites});

  @override
  List<Object?> get props => [data, favorites];
}

class BhajanListError extends BhajanListState {
  final String errorMessage;

  BhajanListError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
