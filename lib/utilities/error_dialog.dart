import 'package:flutter/material.dart';

Future<void>ShowErrorDialog(BuildContext context, String text) {
  return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('an error was occured'),
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ok'),
            ),
          ],
        );
      },);
}