// lib/domain/repositories/note_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/note.dart';

abstract class NoteRepository {
  Future<Either<Failure, List<Note>>> getNotes();
  Future<Either<Failure, Note>> getNoteById(String id);
  Future<Either<Failure, String>> createNote(Note note);
  Future<Either<Failure, String>> updateNote(Note note);
  Future<Either<Failure, String>> deleteNote(String id);
  Future<Either<Failure, void>> syncNotes();
}
