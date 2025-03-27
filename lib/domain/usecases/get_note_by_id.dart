// lib/domain/usecases/get_note_by_id.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class GetNoteById implements UseCase<Note, NoteParams> {
  final NoteRepository repository;

  GetNoteById(this.repository);

  @override
  Future<Either<Failure, Note>> call(NoteParams params) {
    return repository.getNoteById(params.id);
  }
}

class NoteParams extends Equatable {
  final String id;

  const NoteParams({required this.id});

  @override
  List<Object> get props => [id];
}
