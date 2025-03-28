// lib/presentation/pages/notification_debug_page.dart
import 'package:flutter/material.dart';
import '../../data/services/notification_service.dart';
import '../../di/service_locator.dart';

class NotificationDebugPage extends StatelessWidget {
  const NotificationDebugPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notificationService = sl<NotificationService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Testing')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                notificationService.showTestNotification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Test notification sent!')),
                );
              },
              child: const Text('Immediate Notification'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                notificationService.showScheduledTestNotification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Scheduled notification set for 5 seconds from now',
                    ),
                  ),
                );
              },
              child: const Text('Scheduled Notification (5 sec)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                notificationService.showSyncNotification(
                  title: 'Test Sync Complete',
                  body: 'This is a test of the sync notification channel',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sync notification sent!')),
                );
              },
              child: const Text('Sync Channel Notification'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                notificationService.cancelAllNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications cancelled')),
                );
              },
              child: const Text('Cancel All Notifications'),
            ),
          ],
        ),
      ),
    );
  }
}
