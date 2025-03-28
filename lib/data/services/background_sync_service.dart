import 'dart:async';
import 'package:notes/core/usecases/usecase.dart';
import 'package:notes/domain/usecases/sync_notes.dart';

class BackgroundSyncService {
  final SyncNotes syncNotes;
  Timer? _syncTimer;

  BackgroundSyncService({required this.syncNotes});

  void startPeriodicSync({Duration period = const Duration(minutes: 15)}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(period, (_) async {
      await syncNotes(NoParams());
    });
  }

  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }
}
