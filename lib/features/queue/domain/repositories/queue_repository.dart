import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/queue.dart';

abstract class QueueRepository {
  Future<Either<Failure, Queue>> generateQueue(String serviceId);
  Future<Either<Failure, Queue?>> getActiveQueue();
  Future<Either<Failure, Queue>> getQueueById(String queueId);
  Future<Either<Failure, List<Queue>>> getQueueList(String sectorId);
  Future<Either<Failure, Queue>> updateQueueStatus(String queueId, String status);
  Future<Either<Failure, Queue>> registerWalkIn(String name, String phoneNumber, String serviceId);
}
