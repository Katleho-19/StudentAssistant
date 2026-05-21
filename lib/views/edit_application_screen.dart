import 'package:flutter/material.dart';
import 'package:student_assistant/models/application_model.dart';
import 'package:student_assistant/views/application_form_screen.dart';

class EditApplicationScreen extends StatelessWidget {
  final ApplicationModel application;

  const EditApplicationScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    return ApplicationFormScreen(applicationToEdit: application);
  }
}
