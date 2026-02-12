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

class QueueLoadList extends QueueEvent {
  final String sectorId;

  const QueueLoadList({required this.sectorId});

  @override
  List<Object?> get props => [sectorId];
}

class QueueUpdateStatus extends QueueEvent {
  final String queueId;
  final String status;

  const QueueUpdateStatus({required this.queueId, required this.status});

  @override
  List<Object?> get props => [queueId, status];
}

class QueueRegisterWalkIn extends QueueEvent {
  final String name;
  final String phoneNumber;
  final String serviceId;

  const QueueRegisterWalkIn({
    required this.name,
    required this.phoneNumber,
    required this.serviceId,
  });

  @override
  List<Object?> get props => [name, phoneNumber, serviceId];
}
