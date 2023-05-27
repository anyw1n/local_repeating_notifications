import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:notifications/period.dart';
import 'package:timezone/timezone.dart';

part 'periodic_notification.g.dart';

@JsonSerializable()
class PeriodicNotification {
  PeriodicNotification({
    required this.title,
    required this.content,
    required this.start,
    required this.period,
    required this.end,
  });

  final String title;
  final String content;
  @JsonKey(fromJson: fromString, toJson: toIsoString)
  final TZDateTime start;
  final Period period;
  @JsonKey(fromJson: tryFromString, toJson: toIsoString)
  final TZDateTime? end;

  // В пэйлоад можно добавить все что нужно передать на второй экран (всё что сериализуется)
  String get payload => jsonEncode({
        'title': title,
        'content': content,
      });

  factory PeriodicNotification.fromJson(Map<String, dynamic> json) =>
      _$PeriodicNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$PeriodicNotificationToJson(this);

  static TZDateTime fromString(String string) =>
      TZDateTime.parse(local, string);

  static TZDateTime? tryFromString(String? string) =>
      string != null ? TZDateTime.parse(local, string) : null;

  static String? toIsoString(TZDateTime? date) => date?.toIso8601String();
}
