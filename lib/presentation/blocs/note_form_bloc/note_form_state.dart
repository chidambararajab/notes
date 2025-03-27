// lib/presentation/blocs/note_form_bloc/note_form_state.dart
part of 'note_form_bloc.dart';

abstract class NoteFormState extends Equatable {
  const NoteFormState();

  @override
  List<Object> get props => [];
}

class NoteFormInitial extends NoteFormState {}

class NoteFormLoading extends NoteFormState {}

class NoteFormLoaded extends NoteFormState {
  final String id;
  final String title;
  final String content;
  final bool isEditing;

  const NoteFormLoaded({
    required this.id,
    required this.title,
    required this.content,
    required this.isEditing,
  });

  NoteFormLoaded copyWith({
    String? id,
    String? title,
    String? content,
    bool? isEditing,
  }) {
    return NoteFormLoaded(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isEditing: isEditing ?? this.isEditing,
    );
  }

  @override
  List<Object> get props => [id, title, content, isEditing];
}

class NoteFormSaving extends NoteFormState {}

class NoteFormSuccess extends NoteFormState {}

class NoteFormError extends NoteFormState {
  final String message;

  const NoteFormError(this.message);

  @override
  List<Object> get props => [message];
}
