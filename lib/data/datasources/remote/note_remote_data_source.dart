// lib/data/datasources/remote/note_remote_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/note_model.dart';

abstract class NoteRemoteDataSource {
  Future<List<NoteModel>> getNotes();
  Future<String> createNote(NoteModel note);
  Future<String> updateNote(NoteModel note);
  Future<String> deleteNote(String id);
}

class NoteRemoteDataSourceImpl implements NoteRemoteDataSource {
  final FirebaseFirestore firestore;

  NoteRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<NoteModel>> getNotes() async {
    try {
      final notesCollection = await firestore.collection('notes').get();
      return notesCollection.docs
          .map((doc) => NoteModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<String> createNote(NoteModel note) async {
    try {
      final docRef = await firestore
          .collection('notes')
          .add(note.toFirestore());
      return docRef.id;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<String> updateNote(NoteModel note) async {
    try {
      await firestore
          .collection('notes')
          .doc(note.id)
          .update(note.toFirestore());
      return note.id;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<String> deleteNote(String id) async {
    try {
      await firestore.collection('notes').doc(id).delete();
      return id;
    } catch (e) {
      throw ServerException();
    }
  }
}
