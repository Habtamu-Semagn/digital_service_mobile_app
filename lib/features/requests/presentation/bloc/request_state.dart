part of 'request_bloc.dart';

abstract class RequestState extends Equatable {
  const RequestState();

  @override
  List<Object?> get props => [];
}

class RequestInitial extends RequestState {}

class RequestLoading extends RequestState {}

class RequestSubmitSuccess extends RequestState {
  final String message;

  const RequestSubmitSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class RequestLoaded extends RequestState {
  final List<Request> requests;

  const RequestLoaded({required this.requests});

  @override
  List<Object?> get props => [requests];
}

class RequestError extends RequestState {
  final String message;

  const RequestError({required this.message});

  @override
  List<Object?> get props => [message];
}
