// lib/presentation/blocs/sync_bloc/sync_event.dart
part of 'sync_bloc.dart';

abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object> get props => [];
}

class StartSyncMonitoring extends SyncEvent {
  const StartSyncMonitoring();
}

class StopSyncMonitoring extends SyncEvent {
  const StopSyncMonitoring();
}

class TriggerSync extends SyncEvent {
  const TriggerSync();
}

class ConnectivityChanged extends SyncEvent {
  final bool isConnected;

  const ConnectivityChanged(this.isConnected);

  @override
  List<Object> get props => [isConnected];
}
