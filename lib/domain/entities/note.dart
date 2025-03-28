// Update lib/domain/entities/note.dart to include reminder
import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final DateTime? reminderDate; // New field for reminder

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.reminderDate, // Optional reminder date
  });

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    createdAt,
    updatedAt,
    isSynced,
    reminderDate,
  ];
}
