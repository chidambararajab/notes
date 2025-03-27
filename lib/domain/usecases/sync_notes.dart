// lib/domain/usecases/sync_notes.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/note_repository.dart';

class SyncNotes implements UseCase<void, NoParams> {
  final NoteRepository repository;

  SyncNotes(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.syncNotes();
  }
}
