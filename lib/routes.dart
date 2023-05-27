import 'package:flutter/material.dart' hide Notification;
import 'package:go_router/go_router.dart';
import 'package:notifications/notification_screen.dart';
import 'package:notifications/set_notifications_screen.dart';

part 'routes.g.dart';

// Для навигации используется GoRouter но можно использовать любой тип навигации
@TypedGoRoute<SetNotificationsRoute>(
  path: '/',
  routes: [
    TypedGoRoute<NotificationRoute>(path: 'notification'),
  ],
)
class SetNotificationsRoute extends GoRouteData {
  const SetNotificationsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SetNotificationsScreen();
}

class NotificationRoute extends GoRouteData {
  const NotificationRoute([this.$extra]);

  final Map<String, dynamic>? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      NotificationScreen(payload: $extra!);
}
