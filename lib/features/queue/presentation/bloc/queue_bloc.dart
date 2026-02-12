import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/queue.dart';
import '../../domain/repositories/queue_repository.dart';

part 'queue_event.dart';
part 'queue_state.dart';

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  final QueueRepository queueRepository;
  Timer? _pollingTimer;

  QueueBloc({required this.queueRepository}) : super(QueueInitial()) {
    on<QueueGenerate>(_onGenerateQueue);
    on<QueueLoadActive>(_onLoadActiveQueue);
    on<QueueStartPolling>(_onStartPolling);
    on<QueueStopPolling>(_onStopPolling);
    on<QueueUpdate>(_onUpdateQueue);
    on<QueueLoadList>(_onLoadList);
    on<QueueUpdateStatus>(_onUpdateStatus);
    on<QueueRegisterWalkIn>(_onRegisterWalkIn);
  }

  Future<void> _onGenerateQueue(
    QueueGenerate event,
    Emitter<QueueState> emit,
  ) async {
    emit(QueueLoading());

    final result = await queueRepository.generateQueue(event.serviceId);

    result.fold(
      (failure) => emit(QueueError(message: failure.message)),
      (queue) {
        emit(QueueGenerated(queue: queue));
        // Start polling for updates
        add(QueueStartPolling(queueId: queue.id));
      },
    );
  }

  Future<void> _onLoadActiveQueue(
    QueueLoadActive event,
    Emitter<QueueState> emit,
  ) async {
    emit(QueueLoading());

    final result = await queueRepository.getActiveQueue();

    result.fold(
      (failure) => emit(QueueError(message: failure.message)),
      (queue) {
        if (queue != null) {
          emit(QueueActive(queue: queue));
          // Start polling for updates
          add(QueueStartPolling(queueId: queue.id));
        } else {
          emit(QueueNoActive());
        }
      },
    );
  }

  void _onStartPolling(
    QueueStartPolling event,
    Emitter<QueueState> emit,
  ) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      AppConstants.queuePollingInterval,
      (_) => add(QueueUpdate(queueId: event.queueId)),
    );
  }

  void _onStopPolling(
    QueueStopPolling event,
    Emitter<QueueState> emit,
  ) {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _onUpdateQueue(
    QueueUpdate event,
    Emitter<QueueState> emit,
  ) async {
    // Don't show loading state during polling updates
    final result = await queueRepository.getQueueById(event.queueId);

    result.fold(
      (failure) {
        // If error during polling, stop polling
        add(QueueStopPolling());
        emit(QueueError(message: failure.message));
      },
      (queue) {
        // Check if queue is completed or cancelled
        if (queue.status == AppConstants.queueStatusCompleted ||
            queue.status == AppConstants.queueStatusCancelled ||
            queue.status == AppConstants.queueStatusNoShow) {
          add(QueueStopPolling());
        }
        emit(QueueActive(queue: queue));
      },
    );
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }

  Future<void> _onLoadList(
    QueueLoadList event,
    Emitter<QueueState> emit,
  ) async {
    emit(QueueLoading());
    final result = await queueRepository.getQueueList(event.sectorId);
    result.fold(
      (failure) => emit(QueueError(message: failure.message)),
      (queues) => emit(QueueListLoaded(queues: queues)),
    );
  }

  Future<void> _onUpdateStatus(
    QueueUpdateStatus event,
    Emitter<QueueState> emit,
  ) async {
    emit(QueueLoading());
    final result = await queueRepository.updateQueueStatus(event.queueId, event.status);
    result.fold(
      (failure) => emit(QueueError(message: failure.message)),
      (queue) => emit(QueueActionSuccess(message: 'Status updated to ${event.status}', queue: queue)),
    );
  }

  Future<void> _onRegisterWalkIn(
    QueueRegisterWalkIn event,
    Emitter<QueueState> emit,
  ) async {
    emit(QueueLoading());
    final result = await queueRepository.registerWalkIn(event.name, event.phoneNumber, event.serviceId);
    result.fold(
      (failure) => emit(QueueError(message: failure.message)),
      (queue) => emit(QueueActionSuccess(message: 'Walk-in registered successfully', queue: queue)),
    );
  }
}
