import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digital_service_app/features/admin/domain/repositories/admin_repository.dart';
import 'package:digital_service_app/features/admin/data/models/admin_stats_model.dart';
import 'package:digital_service_app/features/admin/data/models/system_log_model.dart';
import 'package:digital_service_app/features/auth/domain/entities/user.dart';

// Events
abstract class AdminEvent extends Equatable {
  const AdminEvent();
  @override
  List<Object?> get props => [];
}

class AdminLoadStats extends AdminEvent {}
class AdminLoadUsers extends AdminEvent {}
class AdminLoadLogs extends AdminEvent {}

// States
abstract class AdminState extends Equatable {
  const AdminState();
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}
class AdminLoading extends AdminState {}
class AdminStatsLoaded extends AdminState {
  final AdminStats stats;
  const AdminStatsLoaded(this.stats);
  @override
  List<Object?> get props => [stats];
}
class AdminUsersLoaded extends AdminState {
  final List<User> users;
  const AdminUsersLoaded(this.users);
  @override
  List<Object?> get props => [users];
}
class AdminLogsLoaded extends AdminState {
  final List<SystemLog> logs;
  const AdminLogsLoaded(this.logs);
  @override
  List<Object?> get props => [logs];
}
class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository adminRepository;

  AdminBloc({required this.adminRepository}) : super(AdminInitial()) {
    on<AdminLoadStats>(_onLoadStats);
    on<AdminLoadUsers>(_onLoadUsers);
    on<AdminLoadLogs>(_onLoadLogs);
  }

  Future<void> _onLoadStats(AdminLoadStats event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    final result = await adminRepository.getStats();
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (stats) => emit(AdminStatsLoaded(stats)),
    );
  }

  Future<void> _onLoadUsers(AdminLoadUsers event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    final result = await adminRepository.getUsers();
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (users) => emit(AdminUsersLoaded(users)),
    );
  }

  Future<void> _onLoadLogs(AdminLoadLogs event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    final result = await adminRepository.getLogs();
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (logs) => emit(AdminLogsLoaded(logs)),
    );
  }
}
