import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notifications/notification_repository.dart';
import 'package:notifications/notifications_manager.dart';
import 'package:notifications/routes.dart';
import 'package:notifications/schedule_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Запускаем обновление установленных уведомлений при старте приложения
  rescheduleNotification(HeadlessTask('taskId', false));

  // Инициализация необходимых синглтонов
  await Future.wait([
    ScheduleManager().init(),
    NotificationsManager().init(),
    NotificationRepository().init()
  ]);

  runApp(const _App());
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Notifications',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: GoRouter(
        initialLocation: const SetNotificationsRoute().location,
        routes: $appRoutes,
        debugLogDiagnostics: true,
      ),
    );
  }
}
