// Updated lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notes/data/services/background_sync_service.dart';
import 'core/utils/bloc_observer.dart';
import 'data/services/notification_handler.dart';
import 'di/service_locator.dart' as di;
import 'presentation/app.dart';

// Create a navigator key for navigation from notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize dependency injection
  await di.init();

  di.sl<BackgroundSyncService>().startPeriodicSync();

  // Initialize notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      di.sl<FlutterLocalNotificationsPlugin>();
  await NotificationHandler.setupNotificationActions(
    flutterLocalNotificationsPlugin,
    navigatorKey,
  );

  // Set up BLoC observer for debugging
  Bloc.observer = AppBlocObserver();

  runApp(MyApp(navigatorKey: navigatorKey));
}
