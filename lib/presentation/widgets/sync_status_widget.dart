// lib/presentation/widgets/sync_status_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/sync_bloc/sync_bloc.dart';

class SyncStatusWidget extends StatelessWidget {
  const SyncStatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, state) {
        if (state is SyncInProgress) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 8),
              Text('Syncing...'),
            ],
          );
        } else if (state is SyncSuccess) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check, color: Colors.green),
              SizedBox(width: 8),
              Text('Synced'),
            ],
          );
        } else if (state is SyncFailure) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              Text(state.message),
            ],
          );
        } else if (state is SyncStatus) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                state.isConnected ? Icons.wifi : Icons.wifi_off,
                color: state.isConnected ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(state.isConnected ? 'Connected' : 'Offline'),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
