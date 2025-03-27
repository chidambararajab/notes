// lib/presentation/blocs/note_bloc/note_event.dart
part of 'note_bloc.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();

  @override
  List<Object> get props => [];
}

class FetchNotes extends NoteEvent {
  const FetchNotes();
}

class DeleteNoteEvent extends NoteEvent {
  final String id;

  const DeleteNoteEvent(this.id);

  @override
  List<Object> get props => [id];
}

class SyncNotesEvent extends NoteEvent {
  const SyncNotesEvent();
}
