import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_assistant/models/application_model.dart';
import 'package:student_assistant/viewmodels/student_view_model.dart';
import 'package:student_assistant/routes/route_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApplicationFormScreen extends StatefulWidget {
  final ApplicationModel? applicationToEdit;
  const ApplicationFormScreen({super.key, this.applicationToEdit});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool get _isEditMode => widget.applicationToEdit != null;

  final List<String> _courses = [
    'IT 1st Year',
    'IT 2nd Year',
    'Computer Literacy',
    'IT Extended Programme (ECP)',
    'Higher Certificate in IT',
    'Open Lab',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isEditMode) {
        context.read<StudentViewModel>().loadFromApplication(
          widget.applicationToEdit!,
        );
      } else {
        context.read<StudentViewModel>().resetForm();
      }
    });
  }

  Future<void> _submit(StudentViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;

    bool success;
    if (_isEditMode) {
      final userId =
          widget.applicationToEdit?.userId ??
          Supabase.instance.client.auth.currentUser?.id ??
          '';
      success = await vm.updateApplication(
        userId,
        yearOfStudy: vm.yearOfStudy,
        firstModule: vm.module1,
        secondModule: vm.module2,
        eligibilityConfirmed: vm.eligibilityConfirmed,
      );
    } else {
      success = await vm.submitApplication();
    }

    if (!mounted) return;

    if (success) {
      if (_isEditMode) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Application submitted successfully!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteManager.studHome,
          (route) => false,
        );
      }
    } else if (vm.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Application' : 'Apply for Student Assistant',
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Consumer<StudentViewModel>(
        builder: (context, vm, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Year of Study
                  _SectionCard(
                    title: 'Personal Information',
                    child: DropdownButtonFormField<int>(
                      initialValue: vm.yearOfStudy,
                      decoration: const InputDecoration(
                        labelText: 'Current Year of Study',
                        border: OutlineInputBorder(),
                      ),
                      items: [1, 2, 3]
                          .map(
                            (y) => DropdownMenuItem(
                              value: y,
                              child: Text('Year $y'),
                            ),
                          )
                          .toList(),
                      onChanged: vm.setYearOfStudy,
                      validator: vm.validateYearOfStudy,
                    ),
                  ),

                  // First Course
                  _SectionCard(
                    title: 'First Course Selection',
                    subtitle: 'Select the course you wish to assist with.',
                    child: DropdownButtonFormField<String>(
                      initialValue: vm.module1,
                      decoration: const InputDecoration(
                        labelText: 'Course 1',
                        border: OutlineInputBorder(),
                      ),
                      items: _courses
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: vm.setModule1,
                      validator: vm.validateModule1,
                    ),
                  ),

                  // Second Course (Optional)
                  Card(
                    color: Colors.blue.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ExpansionTile(
                      initiallyExpanded:
                          _isEditMode &&
                          widget.applicationToEdit!.secondModule != null,
                      title: const Text('Second Course Selection (Optional)'),
                      subtitle: const Text(
                        'Maximum of 2 courses per application.',
                        style: TextStyle(fontSize: 11),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: DropdownButtonFormField<String?>(
                            initialValue: vm.module2,
                            decoration: const InputDecoration(
                              labelText: 'Course 2',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('None'),
                              ),
                              ..._courses
                                  .where((c) => c != vm.module1)
                                  .map(
                                    (c) => DropdownMenuItem<String?>(
                                      value: c,
                                      child: Text(c),
                                    ),
                                  ),
                            ],
                            onChanged: vm.setModule2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Eligibility & Document
                  _SectionCard(
                    title: 'Eligibility & Documentation',
                    subtitle:
                        'You must not be currently appointed to any position at CUT.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormField<bool>(
                          initialValue: vm.eligibilityConfirmed,
                          validator: vm.validateEligibility,
                          builder: (field) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CheckboxListTile(
                                value: field.value ?? false,
                                title: const Text(
                                  'I confirm I meet all minimum requirements.',
                                  style: TextStyle(fontSize: 13),
                                ),
                                onChanged: (val) {
                                  field.didChange(val);
                                  vm.setEligibilityConfirmed(val ?? false);
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                              ),
                              if (field.errorText != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Text(
                                    field.errorText!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Existing doc notice in edit mode
                        if (_isEditMode &&
                            widget.applicationToEdit?.photo != null &&
                            vm.docFileName == null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Existing document on file. Upload below to replace it.',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        ElevatedButton.icon(
                          onPressed: () => vm.pickDocument(),
                          icon: const Icon(Icons.upload_file),
                          label: Text(
                            vm.docFileName != null
                                ? 'Selected: ${vm.docFileName}'
                                : _isEditMode
                                ? 'Replace Supporting Document (PDF)'
                                : 'Upload Supporting Document (PDF)',
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Upload one PDF: CV, certified ID, Grade 12 certificate, academic record, proof of registration, and cover letter.',
                          style: TextStyle(fontSize: 11, color: Colors.black45),
                        ),
                      ],
                    ),
                  ),

                  if (vm.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        vm.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  Center(
                    child: ElevatedButton(
                      onPressed: vm.isLoading ? null : () => _submit(vm),
                      child: vm.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _isEditMode
                                  ? 'Save Changes'
                                  : 'Submit Application',
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.indigo),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
