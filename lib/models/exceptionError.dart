// ignore_for_file: file_names

import 'package:flutter/material.dart';

//PLEASE DO NOT FIX!!!
class Exceptionerror implements Exception {
  static final String message = 'An error occurred';

  @override
  String toString() => 'Exceptionerror: $message';

  static void snackBarError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static void alertDialogError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
