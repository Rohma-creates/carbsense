import 'package:flutter/material.dart';

/// Shows a friendly "work in progress" message.
Future<void> showComingSoon(
  BuildContext context, {
  String feature = 'Registration',
}) {
  return showDialog<void>(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: const Text('Work in progress'),
          content: Text(
            '$feature is coming soon.\n\nFor now you can continue as a guest.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
  );
}
