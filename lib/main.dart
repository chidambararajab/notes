// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notes/data/services/background_sync_service.dart';
import 'core/utils/bloc_observer.dart';
import 'di/service_locator.dart' as di;
import 'presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize dependency injection
  await di.init();

  // Set up BLoC observer for debugging
  Bloc.observer = AppBlocObserver();

  di.sl<BackgroundSyncService>().startPeriodicSync();

  runApp(const App());
}
