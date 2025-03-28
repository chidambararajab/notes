// lib/presentation/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/app_theme.dart';
import '../di/service_locator.dart';
import '../presentation/blocs/note_bloc/note_bloc.dart';
import '../presentation/blocs/note_form_bloc/note_form_bloc.dart';
import '../presentation/blocs/sync_bloc/sync_bloc.dart';
import '../presentation/navigation/app_router.dart';
import '../presentation/navigation/route_constants.dart';

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({Key? key, required this.navigatorKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NoteBloc>(create: (context) => sl<NoteBloc>()),
        BlocProvider<NoteFormBloc>(create: (context) => sl<NoteFormBloc>()),
        BlocProvider<SyncBloc>(create: (context) => sl<SyncBloc>()),
      ],
      child: MaterialApp(
        title: 'Notes App',
        theme: AppTheme.lightTheme,
        navigatorKey: navigatorKey, // Add navigator key
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: RouteConstants.home,
      ),
    );
  }
}
