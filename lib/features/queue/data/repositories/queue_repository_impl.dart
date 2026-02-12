import 'package:dartz/dartz.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/queue.dart';
import '../../domain/repositories/queue_repository.dart';
import '../datasources/queue_remote_datasource.dart';

class QueueRepositoryImpl implements QueueRepository {
  final QueueRemoteDataSource remoteDataSource;

  QueueRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Queue>> generateQueue(String serviceId) async {
    try {
      final queue = await remoteDataSource.generateQueue(serviceId);
      return Right(queue.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, Queue?>> getActiveQueue() async {
    try {
      final queue = await remoteDataSource.getActiveQueue();
      return Right(queue?.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, Queue>> getQueueById(String queueId) async {
    try {
      final queue = await remoteDataSource.getQueueById(queueId);
      return Right(queue.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<Queue>>> getQueueList(String sectorId) async {
    try {
      final queues = await remoteDataSource.getQueueList(sectorId);
      return Right(queues.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, Queue>> updateQueueStatus(String queueId, String status) async {
    try {
      final queue = await remoteDataSource.updateQueueStatus(queueId, status);
      return Right(queue.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, Queue>> registerWalkIn(String name, String phoneNumber, String serviceId) async {
    try {
      final queue = await remoteDataSource.registerWalkIn(name, phoneNumber, serviceId);
      return Right(queue.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
}
