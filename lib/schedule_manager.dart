import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:notifications/notification_repository.dart';
import 'package:notifications/notifications_manager.dart';
import 'package:notifications/period.dart';
import 'package:timezone/data/latest_10y.dart';
import 'package:timezone/timezone.dart';

// Класс, отвечающий за воркер, который перевыставлялет уведомления
class ScheduleManager {
  static final _instance = ScheduleManager._internal();

  ScheduleManager._internal();

  factory ScheduleManager() => _instance;

  // Если инит из бэкграунда то мы не настраиваем заново воркер
  Future<void> init({bool fromBackground = false}) async {
    initializeTimeZones();
    setLocalLocation(getLocation(await FlutterTimezone.getLocalTimezone()));

    if (!fromBackground) {
      BackgroundFetch.registerHeadlessTask(rescheduleNotification);
      await BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 15,
          stopOnTerminate: false,
          startOnBoot: true,
          enableHeadless: true,
        ),
        (id) => rescheduleNotification(HeadlessTask(id, false)),
        (id) => rescheduleNotification(HeadlessTask(id, true)),
      );
      await BackgroundFetch.scheduleTask(TaskConfig(
        taskId: 'com.transistorsoft.tasker',
        delay: 60 * 60 * 1000,
        periodic: true,
      ));
    }

    debugPrint(
      'ScheduleManager initialized ${fromBackground ? 'from background' : ''}',
    );
  }

  // Функция рассчитывающая даты уведомлений
  List<TZDateTime> getScheduleDates({
    required TZDateTime start,
    required Period period,
    required TZDateTime? end,
  }) {
    final List<TZDateTime> dates = [_getFirstDate(start, period)];
    if (end != null && dates.first.isAfter(end)) {
      return [];
    }

    // Максимум можем установить 64 уведомления
    while (
        (end != null ? dates.last.isBefore(end) : true) && dates.length != 65) {
      dates.add(dates.last.add(Duration(days: period.inDays)));
    }
    dates.removeLast();

    return dates;
  }

  // Дата первого уведомления, если start уже прошел
  TZDateTime _getFirstDate(TZDateTime start, Period period) {
    final now = TZDateTime.now(local);

    while (!start.isAfter(now)) {
      start = start.add(Duration(days: period.inDays));
    }

    return start;
  }
}

// Коллбэк на перевыставление дат уведомлений
// Логика: получаем уведомление из репозитория, если его нет то завершаем работу
// если есть то выставляем заново уведомления
@pragma('vm:entry-point')
Future<void> rescheduleNotification(HeadlessTask task) async {
  debugPrint('Rescheduling... (${task.taskId})');

  if (task.timeout) {
    debugPrint('Timeout');
    BackgroundFetch.finish(task.taskId);
    return;
  }

  final repository = NotificationRepository();
  final notificationsManager = NotificationsManager();

  await Future.wait([
    ScheduleManager().init(fromBackground: true),
    notificationsManager.init(fromBackground: true),
    repository.init(),
  ]);

  final notification = repository.notification;
  if (notification == null) {
    BackgroundFetch.finish(task.taskId);
    return;
  }

  await notificationsManager.schedulePeriodicNotification(notification);

  debugPrint('Rescheduling end.');
  BackgroundFetch.finish(task.taskId);
}
