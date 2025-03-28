// lib/data/services/notification_service.dart
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  static const String _syncChannelId = 'sync_channel';
  static const String _syncChannelName = 'Sync Notifications';
  static const String _syncChannelDesc =
      'Notifications related to data synchronization';

  static const String _reminderChannelId = 'reminders_channel';
  static const String _reminderChannelName = 'Note Reminders';
  static const String _reminderChannelDesc = 'Reminders for your notes';

  NotificationService(this._notificationsPlugin);
  Future<void> init() async {
    // Initialize timezone database for scheduled notifications
    tz_data.initializeTimeZones();

    // Android initialization settings - use the launcher icon temporarily
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // Initialize notification plugin
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    // Initialize with notification callback
    final didInit = await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    print('Notification plugin initialized: $didInit');

    // Request Android permissions (for Android 13+)
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPluginFuture<void> init() async {
  // Initialize timezone database for scheduled notifications
  tz_data.initializeTimeZones();
  
  // Android initialization settings - use the launcher icon temporarily
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS initialization settings
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  // Initialize notification plugin
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  // Initialize with notification callback
  final didInit = await _notificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
  );
  
  print('Notification plugin initialized: $didInit');

  // Request Android permissions (for Android 13+)
  if (Platform.isAndroid) {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation = 
        _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        
    if (androidImplementation != null) {
      try {
        final bool? granted = await androidImplementation.requestPermission();
        print('Android notification permission granted: $granted');
      } catch (e) {
        print('Error requesting Android permissions: $e');
      }
    }
  }

  // Create notification channels for Android
  await _createNotificationChannels();
  
  print('Notification service initialization completed');
}
              >();

      if (androidImplementation != null) {
        try {
          final bool? granted = await androidImplementation.requestPermission();
          print('Android notification permission granted: $granted');
        } catch (e) {
          print('Error requesting Android permissions: $e');
        }
      }
    }

    // Create notification channels for Android
    await _createNotificationChannels();

    print('Notification service initialization completed');
  }

  Future<void> _createNotificationChannels() async {
    // Create sync channel
    AndroidNotificationChannel syncChannel = const AndroidNotificationChannel(
      _syncChannelId,
      _syncChannelName,
      description: _syncChannelDesc,
      importance: Importance.defaultImportance,
    );

    // Create reminders channel
    AndroidNotificationChannel reminderChannel =
        const AndroidNotificationChannel(
          _reminderChannelId,
          _reminderChannelName,
          description: _reminderChannelDesc,
          importance: Importance.high,
        );

    // Create the channels
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(syncChannel);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(reminderChannel);
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    // Handle notification taps
    // You can navigate to specific screens based on the notification payload
    print('Notification clicked: ${response.payload}');
  }

  // Show a simple notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool isSync = true,
  }) async {
    await _notificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          isSync ? _syncChannelId : _reminderChannelId,
          isSync ? _syncChannelName : _reminderChannelName,
          channelDescription: isSync ? _syncChannelDesc : _reminderChannelDesc,
          importance: isSync ? Importance.defaultImportance : Importance.high,
          priority: isSync ? Priority.defaultPriority : Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  // Show a notification about sync status
  Future<void> showSyncNotification({
    required String title,
    required String body,
  }) async {
    await showNotification(
      id: 1, // Using fixed ID for sync notifications
      title: title,
      body: body,
      isSync: true,
    );
  }

  // Schedule a note reminder
  Future<void> scheduleNoteReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? noteId,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: const AndroidNotificationDetails(
          _reminderChannelId,
          _reminderChannelName,
          channelDescription: _reminderChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: noteId,
    );
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // Add this method to your NotificationService class
  Future<void> showTestNotification() async {
    await showNotification(
      id: 9999, // Use a specific ID for test notifications
      title: 'Test Notification',
      body: 'This is a test notification to verify everything is working!',
      payload: 'test_notification',
      isSync: false, // Use the reminders channel for better visibility
    );
  }

  Future<void> showScheduledTestNotification() async {
    final scheduledTime = DateTime.now().add(const Duration(seconds: 5));

    await scheduleNoteReminder(
      id: 9998, // Different ID from the immediate test notification
      title: 'Scheduled Test Notification',
      body:
          'This notification was scheduled to appear 5 seconds after triggering.',
      scheduledDate: scheduledTime,
      noteId: 'test-scheduled',
    );
  }
}
