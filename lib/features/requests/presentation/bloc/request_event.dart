part of 'request_bloc.dart';

abstract class RequestEvent extends Equatable {
  const RequestEvent();

  @override
  List<Object?> get props => [];
}

class RequestSubmitRequested extends RequestEvent {
  final String serviceId;
  final Map<String, dynamic> data;
  final String? remarks;

  const RequestSubmitRequested({
    required this.serviceId,
    required this.data,
    this.remarks,
  });

  @override
  List<Object?> get props => [serviceId, data, remarks];
}

class RequestLoadMy extends RequestEvent {}
