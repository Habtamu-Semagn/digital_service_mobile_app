import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/queue.dart';

abstract class QueueRepository {
  Future<Either<Failure, Queue>> generateQueue(String serviceId);
  Future<Either<Failure, Queue?>> getActiveQueue();
  Future<Either<Failure, Queue>> getQueueById(String queueId);
}
