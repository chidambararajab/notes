// Update lib/data/models/note_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required String id,
    required String title,
    required String content,
    required DateTime createdAt,
    required DateTime updatedAt,
    bool isSynced = false,
    DateTime? reminderDate, // Add reminder support
  }) : super(
         id: id,
         title: title,
         content: content,
         createdAt: createdAt,
         updatedAt: updatedAt,
         isSynced: isSynced,
         reminderDate: reminderDate,
       );

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isSynced: json['is_synced'] == 1,
      reminderDate:
          json['reminder_date'] != null
              ? DateTime.parse(json['reminder_date'])
              : null,
    );
  }

  factory NoteModel.fromFirestore(Map<String, dynamic> json, String id) {
    return NoteModel(
      id: id,
      title: json['title'],
      content: json['content'],
      createdAt: (json['created_at'] as dynamic).toDate(),
      updatedAt: (json['updated_at'] as dynamic).toDate(),
      isSynced: true,
      reminderDate:
          json['reminder_date'] != null
              ? (json['reminder_date'] as dynamic).toDate()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
      'reminder_date': reminderDate?.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    final data = {
      'title': title,
      'content': content,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };

    if (reminderDate != null) {
      data['reminder_date'] = Timestamp.fromDate(reminderDate!);
    }

    return data;
  }

  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
      isSynced: note.isSynced,
      reminderDate: note.reminderDate,
    );
  }
}
