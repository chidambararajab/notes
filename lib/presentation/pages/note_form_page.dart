// Update lib/presentation/pages/note_form_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
                    // Title field
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

                    // Reminder section
                    _buildReminderSection(context, state),

                    const SizedBox(height: 16),

                    // Content field
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

  // New method to build the reminder section
  Widget _buildReminderSection(BuildContext context, NoteFormLoaded state) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reminder',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: state.reminderDate != null,
                  onChanged: (value) {
                    if (value) {
                      // If turning on, show date picker with a default date (tomorrow)
                      _selectReminderDateTime(
                        context,
                        initialDate: DateTime.now().add(
                          const Duration(days: 1),
                        ),
                      );
                    } else {
                      // If turning off, clear the reminder
                      context.read<NoteFormBloc>().add(
                        const ClearNoteReminder(),
                      );
                    }
                  },
                ),
              ],
            ),
            if (state.reminderDate != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date: ${DateFormat('EEE, MMM d, yyyy').format(state.reminderDate!)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_calendar, size: 20),
                    onPressed:
                        () => _selectReminderDateTime(
                          context,
                          initialDate: state.reminderDate,
                        ),
                  ),
                ],
              ),
              Text(
                'Time: ${DateFormat('h:mm a').format(state.reminderDate!)}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Method to show date & time pickers
  Future<void> _selectReminderDateTime(
    BuildContext context, {
    DateTime? initialDate,
  }) async {
    final DateTime now = DateTime.now();
    initialDate ??= now.add(const Duration(days: 1));

    // Show date picker
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          initialDate.isAfter(now)
              ? initialDate
              : now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (pickedDate != null) {
      // Show time picker
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (pickedTime != null) {
        // Combine date and time
        final DateTime reminderDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Add event to update reminder date
        context.read<NoteFormBloc>().add(SetNoteReminder(reminderDateTime));
      }
    }
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
