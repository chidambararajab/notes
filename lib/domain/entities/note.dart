// lib/domain/entities/note.dart
import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  @override
  List<Object> get props => [
    id,
    title,
    content,
    createdAt,
    updatedAt,
    isSynced,
  ];
}
