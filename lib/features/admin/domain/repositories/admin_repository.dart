import 'package:dartz/dartz.dart';
import 'package:digital_service_app/features/admin/data/models/admin_stats_model.dart';
import 'package:digital_service_app/features/admin/data/models/system_log_model.dart';
import 'package:digital_service_app/features/auth/domain/entities/user.dart';
import 'package:digital_service_app/core/error/failures.dart';

abstract class AdminRepository {
  Future<Either<Failure, AdminStats>> getStats();
  Future<Either<Failure, List<User>>> getUsers();
  Future<Either<Failure, List<SystemLog>>> getLogs();
}
