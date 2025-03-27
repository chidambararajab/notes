// lib/presentation/blocs/sync_bloc/sync_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
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
    // Start monitoring connectivity changes
    _connectivitySubscription = Stream.periodic(
      const Duration(seconds: 30),
    ).listen((_) async {
      final isConnected = await networkInfo.isConnected;
      add(ConnectivityChanged(isConnected));
    });

    // Check initial connectivity
    final isConnected = await networkInfo.isConnected;
    emit(SyncStatus(isConnected: isConnected));
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
    emit(SyncStatus(isConnected: event.isConnected));

    if (event.isConnected) {
      // Automatically trigger sync when internet becomes available
      add(const TriggerSync());
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
