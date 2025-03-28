// lib/data/services/notification_handler.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../presentation/navigation/route_constants.dart';

class NotificationHandler {
  static void handleNotificationResponse(
    NotificationResponse notificationResponse,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    // Get the payload (note ID)
    final payload = notificationResponse.payload;

    if (payload != null) {
      // Navigate to edit note page when notification is tapped
      navigatorKey.currentState?.pushNamed(
        RouteConstants.editNote,
        arguments: payload,
      );
    }
  }

  static Future<void> setupNotificationActions(
    FlutterLocalNotificationsPlugin notificationsPlugin,
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    // Set up notification actions
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (notificationResponse) =>
              handleNotificationResponse(notificationResponse, navigatorKey),
    );

    // Check if app was opened from a notification
    final NotificationAppLaunchDetails? launchDetails =
        await notificationsPlugin.getNotificationAppLaunchDetails();

    if (launchDetails != null &&
        launchDetails.didNotificationLaunchApp &&
        launchDetails.notificationResponse != null) {
      handleNotificationResponse(
        launchDetails.notificationResponse!,
        navigatorKey,
      );
    }
  }
}
