// lib/data/repositories/note_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/local/note_local_data_source.dart';
import '../datasources/remote/note_remote_data_source.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDataSource localDataSource;
  final NoteRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  NoteRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Note>>> getNotes() async {
    try {
      final localNotes = await localDataSource.getNotes();
      return Right(localNotes);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Note>> getNoteById(String id) async {
    try {
      final localNote = await localDataSource.getNoteById(id);
      return Right(localNote);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, String>> createNote(Note note) async {
    try {
      final noteModel = NoteModel.fromEntity(note);
      final noteId = await localDataSource.insertNote(noteModel);

      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.createNote(noteModel);
          await localDataSource.markNoteAsSynced(noteId);
        } catch (_) {
          // If syncing fails, we still have the local note
        }
      }

      return Right(noteId);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, String>> updateNote(Note note) async {
    try {
      final noteModel = NoteModel.fromEntity(note);
      final noteId = await localDataSource.updateNote(noteModel);

      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.updateNote(noteModel);
          await localDataSource.markNoteAsSynced(noteId);
        } catch (_) {
          // If syncing fails, we still have the local update
        }
      }

      return Right(noteId);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, String>> deleteNote(String id) async {
    try {
      final noteId = await localDataSource.deleteNote(id);

      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.deleteNote(id);
        } catch (_) {
          // If remote deletion fails, at least local is deleted
        }
      }

      return Right(noteId);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> syncNotes() async {
    if (!(await networkInfo.isConnected)) {
      return const Left(NetworkFailure());
    }

    try {
      final unsyncedNotes = await localDataSource.getUnsyncedNotes();

      for (var note in unsyncedNotes) {
        try {
          await remoteDataSource.updateNote(note);
          await localDataSource.markNoteAsSynced(note.id);
        } catch (_) {
          // Continue with other notes if one fails
        }
      }

      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure());
    } on ServerException {
      return const Left(ServerFailure());
    }
  }
}
