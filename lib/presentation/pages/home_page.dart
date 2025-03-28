// lib/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../di/service_locator.dart';
import '../blocs/note_bloc/note_bloc.dart';
import '../blocs/sync_bloc/sync_bloc.dart';
import '../navigation/route_constants.dart';
import '../widgets/note_item.dart';
import '../widgets/sync_status_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<NoteBloc>().add(const FetchNotes());
    context.read<SyncBloc>().add(const StartSyncMonitoring());
  }

  @override
  void dispose() {
    context.read<SyncBloc>().add(const StopSyncMonitoring());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              context.read<NoteBloc>().add(const SyncNotesEvent());
            },
            tooltip: 'Sync notes',
          ),
          // Add this button for notification testing
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, RouteConstants.notificationDebug);
            },
            tooltip: 'Test Notifications',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(child: SyncStatusWidget()),
          ),
        ],
      ),
      body: BlocBuilder<NoteBloc, NoteState>(
        builder: (context, state) {
          if (state is NotesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotesLoaded) {
            if (state.notes.isEmpty) {
              return const Center(
                child: Text('No notes yet. Create your first note!'),
              );
            }

            return ListView.builder(
              itemCount: state.notes.length,
              itemBuilder: (context, index) {
                final note = state.notes[index];
                return NoteItem(
                  note: note,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      RouteConstants.editNote,
                      arguments: note.id,
                    ).then((_) {
                      context.read<NoteBloc>().add(const FetchNotes());
                    });
                  },
                  onDelete: () {
                    _showDeleteConfirmationDialog(context, note.id);
                  },
                );
              },
            );
          } else if (state is NotesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NoteBloc>().add(const FetchNotes());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, RouteConstants.createNote).then((_) {
            context.read<NoteBloc>().add(const FetchNotes());
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String noteId) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Note'),
            content: const Text('Are you sure you want to delete this note?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.read<NoteBloc>().add(DeleteNoteEvent(noteId));
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
