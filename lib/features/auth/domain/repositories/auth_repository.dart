import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String phoneNumber, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, User>> updateProfile(String name, String phoneNumber);
  Future<Either<Failure, void>> changePassword(String currentPassword, String newPassword);
  Future<bool> isAuthenticated();
}
