// lib/data/datasources/local/note_local_data_source.dart
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/note_model.dart';
import 'database_helper.dart';

abstract class NoteLocalDataSource {
  Future<List<NoteModel>> getNotes();
  Future<NoteModel> getNoteById(String id);
  Future<String> insertNote(NoteModel note);
  Future<String> updateNote(NoteModel note);
  Future<String> deleteNote(String id);
  Future<List<NoteModel>> getUnsyncedNotes();
  Future<void> markNoteAsSynced(String id);
}

class NoteLocalDataSourceImpl implements NoteLocalDataSource {
  final DatabaseHelper dbHelper;

  NoteLocalDataSourceImpl({required this.dbHelper});

  @override
  Future<List<NoteModel>> getNotes() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.table,
        orderBy: '${DatabaseHelper.columnUpdatedAt} DESC',
      );

      return List.generate(maps.length, (i) => NoteModel.fromJson(maps[i]));
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<NoteModel> getNoteById(String id) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.table,
        where: '${DatabaseHelper.columnId} = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return NoteModel.fromJson(maps.first);
      } else {
        throw CacheException();
      }
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<String> insertNote(NoteModel note) async {
    try {
      final db = await dbHelper.database;
      await db.insert(
        DatabaseHelper.table,
        note.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return note.id;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<String> updateNote(NoteModel note) async {
    try {
      final db = await dbHelper.database;
      await db.update(
        DatabaseHelper.table,
        note.toJson(),
        where: '${DatabaseHelper.columnId} = ?',
        whereArgs: [note.id],
      );
      return note.id;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<String> deleteNote(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        DatabaseHelper.table,
        where: '${DatabaseHelper.columnId} = ?',
        whereArgs: [id],
      );
      return id;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<NoteModel>> getUnsyncedNotes() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.table,
        where: '${DatabaseHelper.columnIsSynced} = ?',
        whereArgs: [0], // 0 means not synced
      );

      return List.generate(maps.length, (i) => NoteModel.fromJson(maps[i]));
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> markNoteAsSynced(String id) async {
    try {
      final db = await dbHelper.database;
      await db.update(
        DatabaseHelper.table,
        {DatabaseHelper.columnIsSynced: 1},
        where: '${DatabaseHelper.columnId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw CacheException();
    }
  }
}
