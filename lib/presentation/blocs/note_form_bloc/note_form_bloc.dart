// Update lib/presentation/blocs/note_form_bloc/note_form_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../di/service_locator.dart';
import '../../../data/services/notification_service.dart';
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
  final NotificationService _notificationService = sl<NotificationService>();

  NoteFormBloc({
    required this.getNoteById,
    required this.createNote,
    required this.updateNote,
  }) : super(NoteFormInitial()) {
    on<InitializeNoteForm>(_onInitializeNoteForm);
    on<ChangeNoteTitle>(_onChangeNoteTitle);
    on<ChangeNoteContent>(_onChangeNoteContent);
    on<SetNoteReminder>(_onSetNoteReminder);
    on<ClearNoteReminder>(_onClearNoteReminder);
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
            reminderDate: note.reminderDate,
            isEditing: true,
          ),
        ),
      );
    } else {
      emit(
        const NoteFormLoaded(
          id: '',
          title: '',
          content: '',
          reminderDate: null,
          isEditing: false,
        ),
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

  void _onSetNoteReminder(SetNoteReminder event, Emitter<NoteFormState> emit) {
    if (state is NoteFormLoaded) {
      final currentState = state as NoteFormLoaded;
      emit(currentState.copyWith(reminderDate: event.reminderDate));
    }
  }

  void _onClearNoteReminder(
    ClearNoteReminder event,
    Emitter<NoteFormState> emit,
  ) {
    if (state is NoteFormLoaded) {
      final currentState = state as NoteFormLoaded;
      emit(currentState.copyWith(reminderDate: null));
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
          reminderDate: currentState.reminderDate,
        );

        final result = await updateNote(UpdateNoteParams(note: note));

        result.fold(
          (failure) => emit(const NoteFormError('Failed to update note')),
          (_) {
            _handleReminderNotification(note);
            emit(NoteFormSuccess());
          },
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
          reminderDate: currentState.reminderDate,
        );

        final result = await createNote(CreateNoteParams(note: note));

        result.fold(
          (failure) => emit(const NoteFormError('Failed to create note')),
          (_) {
            _handleReminderNotification(note);
            emit(NoteFormSuccess());
          },
        );
      }
    }
  }

  void _handleReminderNotification(Note note) {
    // Convert the note ID to an integer hash for notification ID
    final int notificationId = note.id.hashCode;

    // If there's a reminder date set in the future
    if (note.reminderDate != null &&
        note.reminderDate!.isAfter(DateTime.now())) {
      // Schedule a notification
      _notificationService.scheduleNoteReminder(
        id: notificationId,
        title: 'Reminder: ${note.title}',
        body:
            note.content.length > 100
                ? '${note.content.substring(0, 97)}...'
                : note.content,
        scheduledDate: note.reminderDate!,
        noteId: note.id,
      );
    } else if (note.reminderDate == null) {
      // If reminder was removed, cancel any existing notification
      _notificationService.cancelNotification(notificationId);
    }
  }
}
