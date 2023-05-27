import 'package:flutter/material.dart' hide Notification;
import 'package:go_router/go_router.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({
    Key? key,
    required this.payload,
  }) : super(key: key);

  final Map<String, dynamic> payload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(payload['title']!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(payload['content']!),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: context.pop,
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
