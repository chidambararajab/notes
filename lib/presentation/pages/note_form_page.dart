// lib/presentation/pages/note_form_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/note_form_bloc/note_form_bloc.dart';

class NoteFormPage extends StatefulWidget {
  final String? noteId;

  const NoteFormPage({Key? key, this.noteId}) : super(key: key);

  @override
  State<NoteFormPage> createState() => _NoteFormPageState();
}

class _NoteFormPageState extends State<NoteFormPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<NoteFormBloc>().add(InitializeNoteForm(id: widget.noteId));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show confirmation dialog if there are unsaved changes
        if (_titleController.text.isNotEmpty ||
            _contentController.text.isNotEmpty) {
          return await _showDiscardChangesDialog(context) ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<NoteFormBloc, NoteFormState>(
            builder: (context, state) {
              if (state is NoteFormLoaded) {
                return Text(state.isEditing ? 'Edit Note' : 'Create Note');
              }
              return const Text('Note');
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                _saveNote();
              },
            ),
          ],
        ),
        body: BlocConsumer<NoteFormBloc, NoteFormState>(
          listener: (context, state) {
            if (state is NoteFormSuccess) {
              Navigator.pop(context);
            } else if (state is NoteFormError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is NoteFormLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NoteFormLoaded) {
              // Update controllers if needed
              if (_titleController.text != state.title) {
                _titleController.text = state.title;
              }
              if (_contentController.text != state.content) {
                _contentController.text = state.content;
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        context.read<NoteFormBloc>().add(
                          ChangeNoteTitle(value),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TextField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          labelText: 'Content',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        onChanged: (value) {
                          context.read<NoteFormBloc>().add(
                            ChangeNoteContent(value),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: BlocBuilder<NoteFormBloc, NoteFormState>(
          builder: (context, state) {
            if (state is NoteFormSaving) {
              return const FloatingActionButton(
                onPressed: null,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }

            return FloatingActionButton(
              onPressed: () {
                _saveNote();
              },
              child: const Icon(Icons.save),
            );
          },
        ),
      ),
    );
  }

  void _saveNote() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Title cannot be empty')));
      return;
    }

    context.read<NoteFormBloc>().add(const SaveNote());
  }

  Future<bool?> _showDiscardChangesDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Discard Changes'),
            content: const Text(
              'Are you sure you want to discard your changes?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
                child: const Text(
                  'Discard',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
