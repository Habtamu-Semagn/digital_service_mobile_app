part of 'queue_bloc.dart';

abstract class QueueState extends Equatable {
  const QueueState();

  @override
  List<Object?> get props => [];
}

class QueueInitial extends QueueState {}

class QueueLoading extends QueueState {}

class QueueGenerated extends QueueState {
  final Queue queue;

  const QueueGenerated({required this.queue});

  @override
  List<Object?> get props => [queue];
}

class QueueActive extends QueueState {
  final Queue queue;

  const QueueActive({required this.queue});

  @override
  List<Object?> get props => [queue];
}

class QueueNoActive extends QueueState {}

class QueueError extends QueueState {
  final String message;

  const QueueError({required this.message});

  @override
  List<Object?> get props => [message];
}
