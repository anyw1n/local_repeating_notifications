// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'periodic_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PeriodicNotification _$PeriodicNotificationFromJson(
        Map<String, dynamic> json) =>
    PeriodicNotification(
      title: json['title'] as String,
      content: json['content'] as String,
      start: PeriodicNotification.fromString(json['start'] as String),
      period: $enumDecode(_$PeriodEnumMap, json['period']),
      end: PeriodicNotification.tryFromString(json['end'] as String?),
    );

Map<String, dynamic> _$PeriodicNotificationToJson(
        PeriodicNotification instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'start': PeriodicNotification.toIsoString(instance.start),
      'period': _$PeriodEnumMap[instance.period]!,
      'end': PeriodicNotification.toIsoString(instance.end),
    };

const _$PeriodEnumMap = {
  Period.everyDay: 'everyDay',
  Period.inOneDay: 'inOneDay',
  Period.inTwoDays: 'inTwoDays',
};
