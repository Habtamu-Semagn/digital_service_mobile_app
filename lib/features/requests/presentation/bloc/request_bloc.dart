import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/request.dart';
import '../../domain/repositories/request_repository.dart';

part 'request_event.dart';
part 'request_state.dart';

class RequestBloc extends Bloc<RequestEvent, RequestState> {
  final RequestRepository requestRepository;

  RequestBloc({required this.requestRepository}) : super(RequestInitial()) {
    on<RequestSubmitRequested>(_onSubmitRequested);
    on<RequestLoadMy>(_onLoadMy);
  }

  Future<void> _onSubmitRequested(
    RequestSubmitRequested event,
    Emitter<RequestState> emit,
  ) async {
    emit(RequestLoading());

    final result = await requestRepository.submitRequest(
      serviceId: event.serviceId,
      data: event.data,
      remarks: event.remarks,
    );

    result.fold(
      (failure) => emit(RequestError(message: failure.message)),
      (_) => emit(const RequestSubmitSuccess(message: 'Request submitted successfully')),
    );
  }

  Future<void> _onLoadMy(
    RequestLoadMy event,
    Emitter<RequestState> emit,
  ) async {
    emit(RequestLoading());

    final result = await requestRepository.getMyRequests();

    result.fold(
      (failure) => emit(RequestError(message: failure.message)),
      (requests) => emit(RequestLoaded(requests: requests)),
    );
  }
}
