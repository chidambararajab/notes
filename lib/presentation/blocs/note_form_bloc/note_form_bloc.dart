// lib/presentation/blocs/note_form_bloc/note_form_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/usecases/create_note.dart';
import '../../../domain/usecases/get_note_by_id.dart';
import '../../../domain/usecases/update_note.dart';

part 'note_form_event.dart';
part 'note_form_state.dart';

class NoteFormBloc extends Bloc<NoteFormEvent, NoteFormState> {
  final GetNoteById getNoteById;
  final CreateNote createNote;
  final UpdateNote updateNote;

  NoteFormBloc({
    required this.getNoteById,
    required this.createNote,
    required this.updateNote,
  }) : super(NoteFormInitial()) {
    on<InitializeNoteForm>(_onInitializeNoteForm);
    on<ChangeNoteTitle>(_onChangeNoteTitle);
    on<ChangeNoteContent>(_onChangeNoteContent);
    on<SaveNote>(_onSaveNote);
  }

  Future<void> _onInitializeNoteForm(
    InitializeNoteForm event,
    Emitter<NoteFormState> emit,
  ) async {
    emit(NoteFormLoading());

    if (event.id != null) {
      final result = await getNoteById(NoteParams(id: event.id!));

      result.fold(
        (failure) => emit(const NoteFormError('Failed to load note')),
        (note) => emit(
          NoteFormLoaded(
            id: note.id,
            title: note.title,
            content: note.content,
            isEditing: true,
          ),
        ),
      );
    } else {
      emit(
        const NoteFormLoaded(id: '', title: '', content: '', isEditing: false),
      );
    }
  }

  void _onChangeNoteTitle(ChangeNoteTitle event, Emitter<NoteFormState> emit) {
    if (state is NoteFormLoaded) {
      final currentState = state as NoteFormLoaded;
      emit(currentState.copyWith(title: event.title));
    }
  }

  void _onChangeNoteContent(
    ChangeNoteContent event,
    Emitter<NoteFormState> emit,
  ) {
    if (state is NoteFormLoaded) {
      final currentState = state as NoteFormLoaded;
      emit(currentState.copyWith(content: event.content));
    }
  }

  Future<void> _onSaveNote(SaveNote event, Emitter<NoteFormState> emit) async {
    if (state is NoteFormLoaded) {
      final currentState = state as NoteFormLoaded;
      emit(NoteFormSaving());

      final now = DateTime.now();

      if (currentState.isEditing) {
        // Update existing note
        final note = Note(
          id: currentState.id,
          title: currentState.title,
          content: currentState.content,
          createdAt: event.createdAt ?? now,
          updatedAt: now,
        );

        final result = await updateNote(UpdateNoteParams(note: note));

        result.fold(
          (failure) => emit(const NoteFormError('Failed to update note')),
          (_) => emit(NoteFormSuccess()),
        );
      } else {
        // Create new note
        final id = const Uuid().v4();
        final note = Note(
          id: id,
          title: currentState.title,
          content: currentState.content,
          createdAt: now,
          updatedAt: now,
        );

        final result = await createNote(CreateNoteParams(note: note));

        result.fold(
          (failure) => emit(const NoteFormError('Failed to create note')),
          (_) => emit(NoteFormSuccess()),
        );
      }
    }
  }
}
