import 'dart:convert';
import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/secure_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService storage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storage,
  });

  @override
  Future<Either<Failure, User>> login(String phoneNumber, String password) async {
    // Development Bypass for lost credentials
    if (phoneNumber == '0000000000' && password == 'admin123') {
      final user = User(
        id: 'dev-bypass-id',
        email: 'dev@example.com',
        fullName: 'Dev User',
        role: 'CITIZEN',
        phoneNumber: '0000000000',
        createdAt: DateTime.now(),
      );

      // Save dummy tokens
      await storage.writeSecure(AppConstants.keyAccessToken, 'dev-dummy-access-token');
      await storage.writeSecure(AppConstants.keyRefreshToken, 'dev-dummy-refresh-token');
      
      // Save dummy user data
      final userModel = UserModel.fromEntity(user);
      await storage.writeJson(AppConstants.keyUserData, userModel.toJson());

      return Right(user);
    }

    try {
      final response = await remoteDataSource.login(phoneNumber, password);

      // Save tokens
      await storage.writeSecure(
        AppConstants.keyAccessToken,
        response.data.token,
      );
      await storage.writeSecure(
        AppConstants.keyRefreshToken,
        response.data.refreshToken,
      );

      // Save user data
      await storage.writeJson(
        AppConstants.keyUserData,
        response.data.user.toJson(),
      );

      return Right(response.data.user.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      
      // Clear all stored data
      await storage.deleteSecure(AppConstants.keyAccessToken);
      await storage.deleteSecure(AppConstants.keyRefreshToken);
      await storage.remove(AppConstants.keyUserData);

      return const Right(null);
    } catch (e) {
      // Even if API call fails, clear local data
      await storage.deleteSecure(AppConstants.keyAccessToken);
      await storage.deleteSecure(AppConstants.keyRefreshToken);
      await storage.remove(AppConstants.keyUserData);
      
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final userData = storage.readJson(AppConstants.keyUserData);

      if (userData == null) {
        throw CacheException('No user data found');
      }

      final userModel = UserModel.fromJson(userData);
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile(String name, String phoneNumber) async {
    try {
      final userModel = await remoteDataSource.updateProfile(name, phoneNumber);
      
      // Get existing data to merge
      final existingData = storage.readJson(AppConstants.keyUserData);
      Map<String, dynamic> updatedData;
      
      if (existingData != null) {
        updatedData = Map<String, dynamic>.from(existingData);
        final newData = userModel.toJson();
        
        // Merge non-null fields
        newData.forEach((key, value) {
          if (value != null) {
            updatedData[key] = value;
          }
        });

        // Handle specific field fallback from backend 'name' to 'fullName'
        if (userModel.name != null) {
          updatedData['fullName'] = userModel.name;
        }
      } else {
        updatedData = userModel.toJson();
      }

      // Update local cache
      await storage.writeJson(
        AppConstants.keyUserData,
        updatedData,
      );

      final updatedUserModel = UserModel.fromJson(updatedData);
      return Right(updatedUserModel.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(String currentPassword, String newPassword) async {
    try {
      await remoteDataSource.changePassword(currentPassword, newPassword);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await storage.readSecure(AppConstants.keyAccessToken);
    return token != null && token.isNotEmpty;
  }
}
