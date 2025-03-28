// lib/presentation/navigation/app_router.dart
import 'package:flutter/material.dart';
import 'package:notes/presentation/pages/notification_debug_page.dart';
import '../../domain/entities/note.dart';
import '../pages/home_page.dart';
import '../pages/note_form_page.dart';
import 'route_constants.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.home:
        return MaterialPageRoute(builder: (_) => const HomePage());

      case RouteConstants.createNote:
        return MaterialPageRoute(builder: (_) => const NoteFormPage());

      case RouteConstants.editNote:
        final String noteId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => NoteFormPage(noteId: noteId));

      // Add this case
      case RouteConstants.notificationDebug:
        return MaterialPageRoute(builder: (_) => const NotificationDebugPage());

      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
