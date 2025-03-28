// lib/presentation/blocs/sync_bloc/sync_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:notes/data/services/notification_service.dart';
import 'package:notes/di/service_locator.dart';
import '../../../core/network/network_info.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/usecases/sync_notes.dart';

part 'sync_event.dart';
part 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncNotes syncNotes;
  final NetworkInfo networkInfo;
  final NotificationService _notificationService = sl<NotificationService>();
  StreamSubscription? _connectivitySubscription;

  SyncBloc({required this.syncNotes, required this.networkInfo})
    : super(SyncInitial()) {
    on<StartSyncMonitoring>(_onStartSyncMonitoring);
    on<StopSyncMonitoring>(_onStopSyncMonitoring);
    on<TriggerSync>(_onTriggerSync);
    on<ConnectivityChanged>(_onConnectivityChanged);
  }

  Future<void> _onStartSyncMonitoring(
    StartSyncMonitoring event,
    Emitter<SyncState> emit,
  ) async {
    // Initialize with current connectivity status
    final isConnected = await networkInfo.isConnected;
    emit(SyncStatus(isConnected: isConnected));

    // Use actual connectivity stream instead of timer-based polling
    _connectivitySubscription = InternetConnectionChecker().onStatusChange
        .listen((status) {
          final isConnected = status == InternetConnectionStatus.connected;
          add(ConnectivityChanged(isConnected));
        });
  }

  void _onStopSyncMonitoring(
    StopSyncMonitoring event,
    Emitter<SyncState> emit,
  ) {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  // Update the _onTriggerSync method
  Future<void> _onTriggerSync(
    TriggerSync event,
    Emitter<SyncState> emit,
  ) async {
    final isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      emit(const SyncFailure('No internet connection'));
      _notificationService.showSyncNotification(
        title: 'Sync Failed',
        body: 'No internet connection available. Will retry when connected.',
      );
      return;
    }

    emit(SyncInProgress());
    _notificationService.showSyncNotification(
      title: 'Syncing Notes',
      body: 'Syncing your notes with the cloud...',
    );

    final result = await syncNotes(NoParams());

    result.fold(
      (failure) {
        emit(const SyncFailure('Failed to sync notes'));
        _notificationService.showSyncNotification(
          title: 'Sync Failed',
          body:
              'There was a problem syncing your notes. Please try again later.',
        );
      },
      (_) {
        emit(SyncSuccess());
        _notificationService.showSyncNotification(
          title: 'Sync Complete',
          body: 'Your notes have been successfully synced to the cloud.',
        );
      },
    );
  }

  // Update the _onConnectivityChanged method
  Future<void> _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<SyncState> emit,
  ) async {
    emit(SyncStatus(isConnected: event.isConnected));

    if (event.isConnected) {
      // Show notification when connection is restored
      _notificationService.showSyncNotification(
        title: 'Connection Restored',
        body: 'Internet connection restored. Starting sync...',
      );

      // Automatically trigger sync when internet becomes available
      add(const TriggerSync());
    } else {
      // Notify when connection is lost
      _notificationService.showSyncNotification(
        title: 'Connection Lost',
        body:
            'Internet connection lost. Changes will be synced when connection is restored.',
      );
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
