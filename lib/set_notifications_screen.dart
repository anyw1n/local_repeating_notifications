import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:notifications/notification_repository.dart';
import 'package:notifications/notifications_manager.dart';
import 'package:notifications/period.dart';
import 'package:notifications/periodic_notification.dart';
import 'package:notifications/routes.dart';
import 'package:timezone/timezone.dart';

class SetNotificationsScreen extends StatelessWidget {
  const SetNotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add notifications"),
      ),
      body: const _BodyWidget(),
    );
  }
}

class _BodyWidget extends StatefulWidget {
  const _BodyWidget({Key? key}) : super(key: key);

  @override
  State<_BodyWidget> createState() => _BodyWidgetState();
}

class _BodyWidgetState extends State<_BodyWidget> {
  final _key = GlobalKey<FormBuilderState>();

  late final StreamSubscription _subscription;

  // Проверка на запуск приложения через нажатие на уведомление
  // (background notification click listener)
  void _checkLaunchFromNotification() async {
    final payload =
        (await NotificationsManager().ifLaunchFromNotification)?.payload;
    if (payload == null) {
      return;
    }
    if (mounted) {
      NotificationRoute(jsonDecode(payload)).go(context);
    }
  }

  void onSave() async {
    final state = _key.currentState?..save();

    if (state == null || !state.validate(focusOnInvalid: false)) {
      return;
    }

    final start = state.value['start'];
    final time = state.value['time'];
    final end = state.value['end'];

    final notification = PeriodicNotification(
      title: state.value['title'],
      content: state.value['content'],
      start: TZDateTime(
        local,
        start.year,
        start.month,
        start.day,
        time.hour,
        time.minute,
      ),
      period: state.value['period'],
      end: end != null
          ? TZDateTime(
              local,
              end.year,
              end.month,
              end.day + 1,
            )
          : null,
    );

    NotificationRepository().save(notification);
    final next =
        await NotificationsManager().schedulePeriodicNotification(notification);

    final message = next != null
        ? 'Success! Next notification will fire up at ${next.day}.${next.month}.${next.year}, ${next.hour}:${next.minute}'
        : 'No notifications set up';

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text(message),
      ));
    }
  }

  @override
  void initState() {
    // Слушаем стрим который отвечает за нажатие уведомления пока приложение в foreground
    // (foreground notification click listener)
    _subscription = NotificationsManager()
        .foregroundNotificationsStream
        .listen((payload) => NotificationRoute(payload).go(context));
    _checkLaunchFromNotification();
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FormBuilder(
        key: _key,
        child: ListView(
          children: [
            FormBuilderDateTimePicker(
              name: 'start',
              decoration: const InputDecoration(labelText: 'Start date*'),
              inputType: InputType.date,
              validator: FormBuilderValidators.required(),
            ),
            FormBuilderDateTimePicker(
              name: 'end',
              decoration: const InputDecoration(labelText: 'End date'),
              inputType: InputType.date,
              validator: (end) {
                final start =
                    _key.currentState?.fields['start']?.value as DateTime?;
                return end != null && start != null && end.isBefore(start)
                    ? "End date must be after start date"
                    : null;
              },
            ),
            FormBuilderDropdown(
              name: 'period',
              decoration: const InputDecoration(labelText: 'Period*'),
              items: Period.values
                  .map((period) => DropdownMenuItem(
                        value: period,
                        child: Text(period.name),
                      ))
                  .toList(),
              validator: FormBuilderValidators.required(),
            ),
            FormBuilderDateTimePicker(
              name: 'time',
              decoration: const InputDecoration(labelText: 'Time*'),
              inputType: InputType.time,
              validator: FormBuilderValidators.required(),
            ),
            FormBuilderTextField(
              name: 'title',
              decoration: const InputDecoration(labelText: 'Title*'),
              validator: FormBuilderValidators.required(),
            ),
            FormBuilderTextField(
              name: 'content',
              decoration: const InputDecoration(labelText: 'Content*'),
              validator: FormBuilderValidators.required(),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSave,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
