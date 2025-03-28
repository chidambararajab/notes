// lib/presentation/blocs/sync_bloc/sync_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../../core/network/network_info.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/usecases/sync_notes.dart';

part 'sync_event.dart';
part 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncNotes syncNotes;
  final NetworkInfo networkInfo;
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

  Future<void> _onTriggerSync(
    TriggerSync event,
    Emitter<SyncState> emit,
  ) async {
    final isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      emit(const SyncFailure('No internet connection'));
      return;
    }

    emit(SyncInProgress());

    final result = await syncNotes(NoParams());

    result.fold(
      (failure) => emit(const SyncFailure('Failed to sync notes')),
      (_) => emit(SyncSuccess()),
    );
  }

  Future<void> _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<SyncState> emit,
  ) async {
    // Previous connectivity state
    final previousState = state;
    bool wasConnected = false;
    if (previousState is SyncStatus) {
      wasConnected = previousState.isConnected;
    }

    // Current connectivity state
    emit(SyncStatus(isConnected: event.isConnected));

    // If connectivity was restored (was offline, now online)
    if (!wasConnected && event.isConnected) {
      // _notificationService.showSyncNotification(
      //   title: 'Connection Restored',
      //   body: 'Internet connection restored. Starting sync...',
      // );

      // Trigger sync when internet becomes available
      add(const TriggerSync());
    } else if (wasConnected && !event.isConnected) {
      // Notify when connection is lost
      // _notificationService.showSyncNotification(
      //   title: 'Connection Lost',
      //   body: 'Internet connection lost. Changes will be synced when connection is restored.',
      // );
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
