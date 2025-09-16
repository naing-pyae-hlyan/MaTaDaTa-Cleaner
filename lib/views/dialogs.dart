import 'package:clean_metadata/models/consts.dart';
import 'package:flutter/material.dart';

class MyDialogs {
  static void showConfirmPopup(
    BuildContext context, {
    required String content,
    required Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: const Text("Confirm!"),
        content: Text(content),
        backgroundColor: backgroundColor,
        surfaceTintColor: backgroundColor,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(
              backgroundColor: backgroundColor,
              surfaceTintColor: backgroundColor,
            ),
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(true);
              onConfirm();
            },
            style: TextButton.styleFrom(
              backgroundColor: primaryColor,
              surfaceTintColor: primaryColor,
            ),
            child: const Text('Yes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
