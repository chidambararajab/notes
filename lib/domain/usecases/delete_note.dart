// lib/domain/usecases/delete_note.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/note_repository.dart';

class DeleteNote implements UseCase<String, DeleteNoteParams> {
  final NoteRepository repository;

  DeleteNote(this.repository);

  @override
  Future<Either<Failure, String>> call(DeleteNoteParams params) {
    return repository.deleteNote(params.id);
  }
}

class DeleteNoteParams extends Equatable {
  final String id;

  const DeleteNoteParams({required this.id});

  @override
  List<Object> get props => [id];
}
