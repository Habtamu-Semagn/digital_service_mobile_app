import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../appointment/domain/entities/appointment.dart';
import '../../../appointment/domain/repositories/appointment_repository.dart';
import '../../../requests/domain/entities/request.dart';
import '../../../requests/domain/repositories/request_repository.dart';

// Events
abstract class OfficerEvent extends Equatable {
  const OfficerEvent();
  @override
  List<Object?> get props => [];
}

class OfficerLoadSectorData extends OfficerEvent {
  final String sectorId;
  const OfficerLoadSectorData(this.sectorId);
  @override
  List<Object?> get props => [sectorId];
}

class OfficerUpdateRequestStatus extends OfficerEvent {
  final String requestId;
  final String status;
  final String? remarks;
  final String sectorId;
  const OfficerUpdateRequestStatus({
    required this.requestId,
    required this.status,
    this.remarks,
    required this.sectorId,
  });
  @override
  List<Object?> get props => [requestId, status, remarks, sectorId];
}

// States
abstract class OfficerState extends Equatable {
  const OfficerState();
  @override
  List<Object?> get props => [];
}

class OfficerInitial extends OfficerState {}
class OfficerLoading extends OfficerState {}
class OfficerDataLoaded extends OfficerState {
  final List<Appointment> appointments;
  final List<Request> requests;
  const OfficerDataLoaded({required this.appointments, required this.requests});
  @override
  List<Object?> get props => [appointments, requests];
}
class OfficerActionSuccess extends OfficerState {
  final String message;
  const OfficerActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
class OfficerError extends OfficerState {
  final String message;
  const OfficerError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class OfficerBloc extends Bloc<OfficerEvent, OfficerState> {
  final AppointmentRepository appointmentRepository;
  final RequestRepository requestRepository;

  OfficerBloc({
    required this.appointmentRepository,
    required this.requestRepository,
  }) : super(OfficerInitial()) {
    on<OfficerLoadSectorData>(_onLoadSectorData);
    on<OfficerUpdateRequestStatus>(_onUpdateRequestStatus);
  }

  Future<void> _onLoadSectorData(OfficerLoadSectorData event, Emitter<OfficerState> emit) async {
    emit(OfficerLoading());
    
    final appResult = await appointmentRepository.getSectorAppointments(event.sectorId);
    final reqResult = await requestRepository.getSectorRequests(event.sectorId);

    appResult.fold(
      (failure) => emit(OfficerError(failure.message)),
      (appointments) {
        reqResult.fold(
          (failure) => emit(OfficerError(failure.message)),
          (requests) => emit(OfficerDataLoaded(appointments: appointments, requests: requests)),
        );
      },
    );
  }

  Future<void> _onUpdateRequestStatus(OfficerUpdateRequestStatus event, Emitter<OfficerState> emit) async {
    emit(OfficerLoading());
    final result = await requestRepository.updateRequestStatus(event.requestId, event.status, event.remarks);
    result.fold(
      (failure) => emit(OfficerError(failure.message)),
      (_) {
        emit(const OfficerActionSuccess('Request status updated'));
        add(OfficerLoadSectorData(event.sectorId));
      },
    );
  }
}
