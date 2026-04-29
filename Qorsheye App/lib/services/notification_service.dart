import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/task_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
      },
    );

    // Request permissions (Android 13+)
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> scheduleTaskNotifications(List<TaskModel> tasks) async {
    // Cancel all existing scheduled notifications first to prevent duplicates
    await _notificationsPlugin.cancelAll();

    final now = DateTime.now();

    for (var task in tasks) {
      if (task.status == 'Completed') continue;
      if (task.dueDate == null) continue;

      final due = task.dueDate!.toLocal();
      
      // Notification details
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'task_reminders',
        'Task Reminders',
        channelDescription: 'Notifications for upcoming and overdue tasks',
        importance: Importance.high,
        priority: Priority.high,
        color: Color(0xFF6C63FF),
      );
      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      if (due.isAfter(now)) {
        // Schedule for the future
        await _notificationsPlugin.zonedSchedule(
          id: task.id,
          title: 'Task Reminder: ${task.title}',
          body: 'This task is due at ${due.hour}:${due.minute.toString().padLeft(2, '0')}.',
          scheduledDate: tz.TZDateTime.from(due, tz.local),
          notificationDetails: platformDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } else {
        // Past / Overdue tasks
        final diff = now.difference(due);
        if (diff.inHours < 24) {
          await _notificationsPlugin.show(
            id: task.id, // Using task ID to prevent duplicate shows
            title: 'Overdue Task: ${task.title}',
            body: 'This task was due at ${due.hour}:${due.minute.toString().padLeft(2, '0')}.',
            notificationDetails: platformDetails,
          );
        }
      }
    }
  }
}
