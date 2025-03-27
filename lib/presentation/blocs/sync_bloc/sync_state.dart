// lib/presentation/blocs/sync_bloc/sync_state.dart
part of 'sync_bloc.dart';

abstract class SyncState extends Equatable {
  const SyncState();

  @override
  List<Object> get props => [];
}

class SyncInitial extends SyncState {}

class SyncStatus extends SyncState {
  final bool isConnected;

  const SyncStatus({required this.isConnected});

  @override
  List<Object> get props => [isConnected];
}

class SyncInProgress extends SyncState {}

class SyncSuccess extends SyncState {}

class SyncFailure extends SyncState {
  final String message;

  const SyncFailure(this.message);

  @override
  List<Object> get props => [message];
}
