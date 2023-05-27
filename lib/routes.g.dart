// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $setNotificationsRoute,
    ];

RouteBase get $setNotificationsRoute => GoRouteData.$route(
      path: '/',
      factory: $SetNotificationsRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: 'notification',
          factory: $NotificationRouteExtension._fromState,
        ),
      ],
    );

extension $SetNotificationsRouteExtension on SetNotificationsRoute {
  static SetNotificationsRoute _fromState(GoRouterState state) =>
      const SetNotificationsRoute();

  String get location => GoRouteData.$location(
        '/',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);
}

extension $NotificationRouteExtension on NotificationRoute {
  static NotificationRoute _fromState(GoRouterState state) => NotificationRoute(
        state.extra as Map<String, dynamic>?,
      );

  String get location => GoRouteData.$location(
        '/notification',
      );

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);
}
