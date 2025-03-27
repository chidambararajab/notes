// lib/domain/usecases/create_note.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class CreateNote implements UseCase<String, CreateNoteParams> {
  final NoteRepository repository;

  CreateNote(this.repository);

  @override
  Future<Either<Failure, String>> call(CreateNoteParams params) {
    return repository.createNote(params.note);
  }
}

class CreateNoteParams extends Equatable {
  final Note note;

  const CreateNoteParams({required this.note});

  @override
  List<Object> get props => [note];
}
