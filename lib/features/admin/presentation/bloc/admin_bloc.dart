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
class AdminLoadSectors extends AdminEvent {}

// Sector Events
class AdminCreateSector extends AdminEvent {
  final Map<String, dynamic> data;
  const AdminCreateSector(this.data);
  @override
  List<Object?> get props => [data];
}
class AdminUpdateSector extends AdminEvent {
  final String id;
  final Map<String, dynamic> data;
  const AdminUpdateSector(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}
class AdminDeleteSector extends AdminEvent {
  final String id;
  const AdminDeleteSector(this.id);
  @override
  List<Object?> get props => [id];
}

// Service Events
class AdminCreateService extends AdminEvent {
  final Map<String, dynamic> data;
  const AdminCreateService(this.data);
  @override
  List<Object?> get props => [data];
}
class AdminUpdateService extends AdminEvent {
  final String id;
  final Map<String, dynamic> data;
  const AdminUpdateService(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}
class AdminDeleteService extends AdminEvent {
  final String id;
  const AdminDeleteService(this.id);
  @override
  List<Object?> get props => [id];
}

// User Events
class AdminUpdateUserRole extends AdminEvent {
  final String userId;
  final String role;
  const AdminUpdateUserRole(this.userId, this.role);
  @override
  List<Object?> get props => [userId, role];
}

class AdminDeleteUser extends AdminEvent {
  final String userId;
  const AdminDeleteUser(this.userId);
  @override
  List<Object?> get props => [userId];
}

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
class AdminSectorsLoaded extends AdminState {
  final List<Map<String, dynamic>> sectors;
  const AdminSectorsLoaded(this.sectors);
  @override
  List<Object?> get props => [sectors];
}
class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);
  @override
  List<Object?> get props => [message];
}

class AdminActionSuccess extends AdminState {
  final String message;
  const AdminActionSuccess(this.message);
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
    on<AdminLoadSectors>(_onLoadSectors);
    
    // Sector handlers
    on<AdminCreateSector>(_onCreateSector);
    on<AdminUpdateSector>(_onUpdateSector);
    on<AdminDeleteSector>(_onDeleteSector);
    
    // Service handlers
    on<AdminCreateService>(_onCreateService);
    on<AdminUpdateService>(_onUpdateService);
    on<AdminDeleteService>(_onDeleteService);

    // User handlers
    on<AdminUpdateUserRole>(_onUpdateUserRole);
    on<AdminDeleteUser>(_onDeleteUser);
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

  Future<void> _onLoadSectors(AdminLoadSectors event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    final result = await adminRepository.getSectors();
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (sectors) => emit(AdminSectorsLoaded(sectors)),
    );
  }

  // Sector Handlers
  Future<void> _onCreateSector(AdminCreateSector event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    final result = await adminRepository.createSector(event.data);
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (_) => emit(const AdminActionSuccess('Sector created successfully')),
    );
  }

  Future<void> _onUpdateSector(AdminUpdateSector event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    final result = await adminRepository.updateSector(event.id, event.data);
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (_) => emit(const AdminActionSuccess('Sector updated successfully')),
    );
  }

  Future<void> _onDeleteSector(AdminDeleteSector event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    final result = await adminRepository.deleteSector(event.id);
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (_) => emit(const AdminActionSuccess('Sector deleted successfully')),
    );
  }

  // Service Handlers
  Future<void> _onCreateService(AdminCreateService event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    final result = await adminRepository.createService(event.data);
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (_) => emit(const AdminActionSuccess('Service created successfully')),
    );
  }

  Future<void> _onUpdateService(AdminUpdateService event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    final result = await adminRepository.updateService(event.id, event.data);
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (_) => emit(const AdminActionSuccess('Service updated successfully')),
    );
  }

  Future<void> _onDeleteService(AdminDeleteService event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    final result = await adminRepository.deleteService(event.id);
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (_) => emit(const AdminActionSuccess('Service deleted successfully')),
    );
  }

  Future<void> _onUpdateUserRole(AdminUpdateUserRole event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    final result = await adminRepository.updateUserRole(event.userId, event.role);
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (_) {
        emit(const AdminActionSuccess('User role updated successfully'));
        add(AdminLoadUsers());
      },
    );
  }

  Future<void> _onDeleteUser(AdminDeleteUser event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    final result = await adminRepository.deleteUser(event.userId);
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (_) {
        emit(const AdminActionSuccess('User deleted successfully'));
        add(AdminLoadUsers());
      },
    );
  }
}
