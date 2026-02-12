import 'package:dartz/dartz.dart';
import 'package:digital_service_app/features/admin/data/models/admin_stats_model.dart';
import 'package:digital_service_app/features/admin/data/models/system_log_model.dart';
import 'package:digital_service_app/features/auth/domain/entities/user.dart';
import 'package:digital_service_app/core/error/failures.dart';

abstract class AdminRepository {
  Future<Either<Failure, AdminStats>> getStats();
  Future<Either<Failure, List<User>>> getUsers();
  Future<Either<Failure, List<SystemLog>>> getLogs();
  
  // Sector Management
  Future<Either<Failure, List<Map<String, dynamic>>>> getSectors();
  Future<Either<Failure, void>> createSector(Map<String, dynamic> sectorData);
  Future<Either<Failure, void>> updateSector(String id, Map<String, dynamic> sectorData);
  Future<Either<Failure, void>> deleteSector(String id);

  // Service Management
  Future<Either<Failure, void>> createService(Map<String, dynamic> serviceData);
  Future<Either<Failure, void>> updateService(String id, Map<String, dynamic> serviceData);
  Future<Either<Failure, void>> deleteService(String id);

  // User Management
  Future<Either<Failure, void>> updateUserRole(String userId, String role);
  Future<Either<Failure, void>> deleteUser(String userId);
}
