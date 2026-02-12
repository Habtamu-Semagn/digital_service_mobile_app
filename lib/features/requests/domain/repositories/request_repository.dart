import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/request.dart';

abstract class RequestRepository {
  Future<Either<Failure, void>> submitRequest({
    required String serviceId,
    required Map<String, dynamic> data,
    String? remarks,
  });
  
  Future<Either<Failure, List<Request>>> getMyRequests();
  Future<Either<Failure, List<Request>>> getSectorRequests(String sectorId);
  Future<Either<Failure, Request>> getRequestById(String requestId);
  Future<Either<Failure, void>> updateRequestStatus(String requestId, String status, String? remarks);
}
