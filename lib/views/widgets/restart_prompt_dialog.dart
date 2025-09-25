import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';

class RestartPromptDialog extends StatelessWidget {
  const RestartPromptDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Restart Required"),
      content: const Text(
          "Data import was successful. Please restart the app to apply changes."),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Dismiss the dialog only
          },
          child: const Text("Later"),
        ),
        ElevatedButton(
          onPressed: () {
            Restart.restartApp();
          },
          child: const Text("Restart Now"),
        ),
      ],
    );
  }
}
