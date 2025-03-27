// lib/presentation/blocs/note_bloc/note_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/usecases/delete_note.dart';
import '../../../domain/usecases/get_notes.dart';
import '../../../domain/usecases/sync_notes.dart';

part 'note_event.dart';
part 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final GetNotes getNotes;
  final DeleteNote deleteNote;
  final SyncNotes syncNotes;

  NoteBloc({
    required this.getNotes,
    required this.deleteNote,
    required this.syncNotes,
  }) : super(NotesInitial()) {
    on<FetchNotes>(_onFetchNotes);
    on<DeleteNoteEvent>(_onDeleteNote);
    on<SyncNotesEvent>(_onSyncNotes);
  }

  Future<void> _onFetchNotes(FetchNotes event, Emitter<NoteState> emit) async {
    emit(NotesLoading());
    final result = await getNotes(NoParams());

    result.fold(
      (failure) => emit(NotesError('Failed to load notes')),
      (notes) => emit(NotesLoaded(notes)),
    );
  }

  Future<void> _onDeleteNote(
    DeleteNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    emit(NotesLoading());
    final result = await deleteNote(DeleteNoteParams(id: event.id));

    result.fold(
      (failure) => emit(NotesError('Failed to delete note')),
      (_) => add(const FetchNotes()),
    );
  }

  Future<void> _onSyncNotes(
    SyncNotesEvent event,
    Emitter<NoteState> emit,
  ) async {
    emit(NotesSyncing());
    final result = await syncNotes(NoParams());

    result.fold((failure) => emit(NotesSyncError('Failed to sync notes')), (_) {
      emit(NotesSynced());
      add(const FetchNotes());
    });
  }
}
