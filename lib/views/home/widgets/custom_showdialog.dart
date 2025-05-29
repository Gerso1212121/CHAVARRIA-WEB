import 'package:flutter/material.dart';

class CustomFeedbackDialog extends StatelessWidget {
  final String title;
  final String message;
  final bool isSuccess;
  final List<Widget>? actions;

  const CustomFeedbackDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.isSuccess,
    this.actions,
  }) : super(key: key);

  void showFeedbackDialog({
    required BuildContext context,
    required String title,
    required String message,
    required bool isSuccess,
    List<Widget>? actions,
  }) {
    showDialog(
      context: context,
      builder: (context) => CustomFeedbackDialog(
        title: title,
        message: message,
        isSuccess: isSuccess,
        actions: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: isSuccess ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 16),
      ),
      actions: actions ??
          [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
    );
  }
}

void showFeedbackDialog({
  required BuildContext context,
  required String title,
  required String message,
  required bool isSuccess,
  List<Widget>? actions,
}) {
  showDialog(
    context: context,
    builder: (context) => CustomFeedbackDialog(
      title: title,
      message: message,
      isSuccess: isSuccess,
      actions: actions,
    ),
  );
}
