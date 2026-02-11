part of 'queue_bloc.dart';

abstract class QueueEvent extends Equatable {
  const QueueEvent();

  @override
  List<Object?> get props => [];
}

class QueueGenerate extends QueueEvent {
  final String serviceId;

  const QueueGenerate({required this.serviceId});

  @override
  List<Object?> get props => [serviceId];
}

class QueueLoadActive extends QueueEvent {}

class QueueStartPolling extends QueueEvent {
  final String queueId;

  const QueueStartPolling({required this.queueId});

  @override
  List<Object?> get props => [queueId];
}

class QueueStopPolling extends QueueEvent {}

class QueueUpdate extends QueueEvent {
  final String queueId;

  const QueueUpdate({required this.queueId});

  @override
  List<Object?> get props => [queueId];
}
