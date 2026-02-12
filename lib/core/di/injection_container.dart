import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/dio_client.dart';
import '../utils/secure_storage_service.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/dashboard/data/datasources/service_remote_datasource.dart';
import '../../features/dashboard/data/repositories/service_repository_impl.dart';
import '../../features/dashboard/domain/repositories/service_repository.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/queue/data/datasources/queue_remote_datasource.dart';
import '../../features/queue/data/repositories/queue_repository_impl.dart';
import '../../features/queue/domain/repositories/queue_repository.dart';
import '../../features/queue/presentation/bloc/queue_bloc.dart';
import '../../features/appointment/data/datasources/appointment_remote_datasource.dart';
import '../../features/appointment/data/repositories/appointment_repository_impl.dart';
import '../../features/appointment/domain/repositories/appointment_repository.dart';
import '../../features/appointment/presentation/bloc/appointment_bloc.dart';
import '../../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../features/requests/data/datasources/request_remote_datasource.dart';
import '../../features/requests/data/repositories/request_repository_impl.dart';
import '../../features/requests/domain/repositories/request_repository.dart';
import '../../features/requests/presentation/bloc/request_bloc.dart';
import '../../features/admin/data/datasources/admin_remote_datasource.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/presentation/bloc/admin_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // External Dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  getIt.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);

  // Core
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(
      getIt<FlutterSecureStorage>(),
      getIt<SharedPreferences>(),
    ),
  );

  getIt.registerLazySingleton<DioClient>(
    () => DioClient(getIt<SecureStorageService>()),
  );

  // Auth Feature
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<DioClient>()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      storage: getIt<SecureStorageService>(),
    ),
  );

  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(authRepository: getIt<AuthRepository>()),
  );

  // Dashboard Feature
  getIt.registerLazySingleton<ServiceRemoteDataSource>(
    () => ServiceRemoteDataSource(getIt<DioClient>()),
  );

  getIt.registerLazySingleton<ServiceRepository>(
    () => ServiceRepositoryImpl(
      remoteDataSource: getIt<ServiceRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<DashboardBloc>(
    () => DashboardBloc(serviceRepository: getIt<ServiceRepository>()),
  );

  // Queue Feature
  getIt.registerLazySingleton<QueueRemoteDataSource>(
    () => QueueRemoteDataSource(getIt<DioClient>()),
  );

  getIt.registerLazySingleton<QueueRepository>(
    () => QueueRepositoryImpl(
      remoteDataSource: getIt<QueueRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<QueueBloc>(
    () => QueueBloc(queueRepository: getIt<QueueRepository>()),
  );

  // Appointment Feature
  getIt.registerLazySingleton<AppointmentRemoteDataSource>(
    () => AppointmentRemoteDataSource(getIt<DioClient>()),
  );

  getIt.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(
      remoteDataSource: getIt<AppointmentRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<AppointmentBloc>(
    () => AppointmentBloc(appointmentRepository: getIt<AppointmentRepository>()),
  );

  // Notifications Feature
  getIt.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSource(getIt<DioClient>()),
  );

  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: getIt<NotificationRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<NotificationBloc>(
    () => NotificationBloc(notificationRepository: getIt<NotificationRepository>()),
  );

  // Requests Feature
  getIt.registerLazySingleton<RequestRemoteDataSource>(
    () => RequestRemoteDataSource(getIt<DioClient>()),
  );

  getIt.registerLazySingleton<RequestRepository>(
    () => RequestRepositoryImpl(
      remoteDataSource: getIt<RequestRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<RequestBloc>(
    () => RequestBloc(requestRepository: getIt<RequestRepository>()),
  );

  // Admin Feature
  getIt.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSource(getIt<DioClient>()),
  );

  getIt.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(
      remoteDataSource: getIt<AdminRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<AdminBloc>(
    () => AdminBloc(adminRepository: getIt<AdminRepository>()),
  );
}
