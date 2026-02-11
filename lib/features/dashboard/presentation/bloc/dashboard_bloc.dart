import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/service.dart';
import '../../domain/repositories/service_repository.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ServiceRepository serviceRepository;

  DashboardBloc({required this.serviceRepository}) : super(DashboardInitial()) {
    on<DashboardLoadServices>(_onLoadServices);
    on<DashboardRefreshServices>(_onRefreshServices);
  }

  Future<void> _onLoadServices(
    DashboardLoadServices event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    final result = await serviceRepository.getServices();

    result.fold(
      (failure) => emit(DashboardError(message: failure.message)),
      (services) => emit(DashboardLoaded(services: services)),
    );
  }

  Future<void> _onRefreshServices(
    DashboardRefreshServices event,
    Emitter<DashboardState> emit,
  ) async {
    // Don't show loading state on refresh
    final result = await serviceRepository.getServices();

    result.fold(
      (failure) => emit(DashboardError(message: failure.message)),
      (services) => emit(DashboardLoaded(services: services)),
    );
  }
}
