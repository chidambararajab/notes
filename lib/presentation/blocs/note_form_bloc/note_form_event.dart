// lib/presentation/blocs/note_form_bloc/note_form_event.dart
part of 'note_form_bloc.dart';

abstract class NoteFormEvent extends Equatable {
  const NoteFormEvent();

  @override
  List<Object?> get props => [];
}

class InitializeNoteForm extends NoteFormEvent {
  final String? id;

  const InitializeNoteForm({this.id});

  @override
  List<Object?> get props => [id];
}

class ChangeNoteTitle extends NoteFormEvent {
  final String title;

  const ChangeNoteTitle(this.title);

  @override
  List<Object> get props => [title];
}

class ChangeNoteContent extends NoteFormEvent {
  final String content;

  const ChangeNoteContent(this.content);

  @override
  List<Object> get props => [content];
}

class SaveNote extends NoteFormEvent {
  final DateTime? createdAt;

  const SaveNote({this.createdAt});

  @override
  List<Object?> get props => [createdAt];
}
