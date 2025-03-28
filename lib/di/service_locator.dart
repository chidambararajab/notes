// lib/di/service_locator.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes/data/services/background_sync_service.dart';
import 'package:notes/data/services/notification_service.dart';
import '../core/network/network_info.dart';
import '../data/datasources/local/database_helper.dart';
import '../data/datasources/local/note_local_data_source.dart';
import '../data/datasources/remote/note_remote_data_source.dart';
import '../data/repositories/note_repository_impl.dart';
import '../domain/repositories/note_repository.dart';
import '../domain/usecases/create_note.dart';
import '../domain/usecases/delete_note.dart';
import '../domain/usecases/get_note_by_id.dart';
import '../domain/usecases/get_notes.dart';
import '../domain/usecases/sync_notes.dart';
import '../domain/usecases/update_note.dart';
import '../presentation/blocs/note_bloc/note_bloc.dart';
import '../presentation/blocs/note_form_bloc/note_form_bloc.dart';
import '../presentation/blocs/sync_bloc/sync_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // BLoCs
  sl.registerFactory(
    () => NoteBloc(getNotes: sl(), deleteNote: sl(), syncNotes: sl()),
  );

  sl.registerFactory(
    () => NoteFormBloc(getNoteById: sl(), createNote: sl(), updateNote: sl()),
  );

  sl.registerFactory(() => SyncBloc(syncNotes: sl(), networkInfo: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetNotes(sl()));
  sl.registerLazySingleton(() => GetNoteById(sl()));
  sl.registerLazySingleton(() => CreateNote(sl()));
  sl.registerLazySingleton(() => UpdateNote(sl()));
  sl.registerLazySingleton(() => DeleteNote(sl()));
  sl.registerLazySingleton(() => SyncNotes(sl()));

  // Repository
  sl.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<NoteLocalDataSource>(
    () => NoteLocalDataSourceImpl(dbHelper: sl()),
  );

  sl.registerLazySingleton<NoteRemoteDataSource>(
    () => NoteRemoteDataSourceImpl(firestore: sl()),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // External
  sl.registerLazySingleton(() => InternetConnectionChecker());
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => DatabaseHelper.instance);

  sl.registerLazySingleton(() => BackgroundSyncService(syncNotes: sl()));

  // Notifications
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());
  sl.registerLazySingleton(() => NotificationService(sl()));
}
