import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notifications/periodic_notification.dart';
import 'package:notifications/schedule_manager.dart';
import 'package:timezone/timezone.dart';

// Синглтон отвечающий за уведомления
class NotificationsManager {
  static final _instance = NotificationsManager._internal();

  NotificationsManager._internal();

  factory NotificationsManager() => _instance;

  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  // Стрим для уведомлений пока приложение не в foreground
  Stream<Map<String, dynamic>> get foregroundNotificationsStream =>
      _controller.stream;

  static const _androidNotificationChannel = AndroidNotificationChannel(
    'default_channel',
    'Basic notifications',
    importance: Importance.max,
  );

  final _notificationsPlugin = FlutterLocalNotificationsPlugin();

  AndroidFlutterLocalNotificationsPlugin? get _androidNotificationsPlugin =>
      _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  IOSFlutterLocalNotificationsPlugin? get _iosNotificationsPlugin =>
      _notificationsPlugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

  // Если приложени было запущено через нажатие на уведомление то возвращает
  // детали, если нет то null
  Future<NotificationResponse?> get ifLaunchFromNotification async {
    final details =
        await _notificationsPlugin.getNotificationAppLaunchDetails();
    final isLaunchFromNotification = details?.didNotificationLaunchApp ?? false;

    return isLaunchFromNotification ? details?.notificationResponse : null;
  }

  // fromBackground Нужна для того, чтобы не запрашивать разрешения когда
  // он инициализируется в бэкграунде
  Future<void> init({bool fromBackground = false}) async {
    const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSetting = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestSoundPermission: false,
      requestBadgePermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSetting,
      iOS: iosSetting,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: !fromBackground
          ? (details) => _controller.add(jsonDecode(details.payload!))
          : null,
    );

    if (!fromBackground) {
      _requestPermissions();
    }

    _androidNotificationsPlugin
        ?.createNotificationChannel(_androidNotificationChannel);

    debugPrint(
      'NotificationsManager initialized ${fromBackground ? 'from background' : ''}',
    );
  }

  void _requestPermissions() {
    _androidNotificationsPlugin?.requestPermission();
    _iosNotificationsPlugin?.requestPermissions(
      alert: true,
      sound: true,
      badge: true,
    );
  }

  Future<TZDateTime?> schedulePeriodicNotification(
    PeriodicNotification notification,
  ) async {
    final scheduledDates = ScheduleManager().getScheduleDates(
      start: notification.start,
      period: notification.period,
      end: notification.end,
    );

    await _notificationsPlugin.cancelAll();
    for (final (i, date) in scheduledDates.indexed) {
      debugPrint(
        'Date: ${date.day}.${date.month}.${date.year}, ${date.hour}:${date.minute}',
      );
      await _scheduleNotification(
        i,
        notification.title,
        notification.content,
        date,
        notification.payload,
      );
    }

    debugPrint('${notification.title} scheduled');
    return scheduledDates.firstOrNull;
  }

  Future<void> _scheduleNotification(
    int id,
    String title,
    String content,
    TZDateTime scheduledDateTime,
    String payload,
  ) async {
    final androidDetails = AndroidNotificationDetails(
      _androidNotificationChannel.id,
      _androidNotificationChannel.name,
      channelDescription: _androidNotificationChannel.description,
      importance: Importance.max,
      priority: Priority.max,
    );
    const iosDetails = DarwinNotificationDetails();

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      content,
      scheduledDateTime,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exact,
    );
  }
}
