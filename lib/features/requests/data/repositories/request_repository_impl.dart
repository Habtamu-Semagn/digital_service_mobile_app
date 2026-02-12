import 'package:dartz/dartz.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/request.dart';
import '../../domain/repositories/request_repository.dart';
import '../datasources/request_remote_datasource.dart';

class RequestRepositoryImpl implements RequestRepository {
  final RequestRemoteDataSource remoteDataSource;

  RequestRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Request>>> getMyRequests() async {
    try {
      final response = await remoteDataSource.getMyRequests();
      return Right(response.data.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, Request>> getRequestById(String requestId) async {
    try {
      final model = await remoteDataSource.getRequestById(requestId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> submitRequest({
    required String serviceId,
    required Map<String, dynamic> data,
    String? remarks,
  }) async {
    try {
      await remoteDataSource.submitRequest(
        serviceId: serviceId,
        data: data,
        remarks: remarks,
      );
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<Request>>> getSectorRequests(String sectorId) async {
    try {
      final models = await remoteDataSource.getSectorRequests(sectorId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateRequestStatus(String requestId, String status, String? remarks) async {
    try {
      await remoteDataSource.updateRequestStatus(requestId, status, remarks);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
}
