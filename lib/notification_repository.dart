import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:notifications/periodic_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Репозиторий для получения и сохранения выставленного уведомления
class NotificationRepository {
  static const _key = 'notification';

  static final _instance = NotificationRepository._internal();

  NotificationRepository._internal();

  factory NotificationRepository() => _instance;

  // Можно использовать любой способ сохранения информации (БД, например)
  SharedPreferences? _prefs;

  PeriodicNotification? get notification {
    final string = _prefs?.getString(_key);
    return string != null
        ? PeriodicNotification.fromJson(jsonDecode(string))
        : null;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    debugPrint('NotificationRepository initialized');
  }

  void save(PeriodicNotification notification) =>
      _prefs?.setString(_key, jsonEncode(notification.toJson()));
}
