import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_assistant/models/application_model.dart';
import 'package:student_assistant/viewmodels/student_view_model.dart';
import 'package:student_assistant/routes/route_manager.dart';

const _kPrimary = Color(0xFF1a1363);
const _kBg = Color(0xFFF1F5F9);

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
      final userId = widget.applicationToEdit?.userId ?? '';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode ? 'Application updated!' : 'Application submitted!',
          ),
          backgroundColor: const Color(0xFF065F46),
        ),
      );
      if (_isEditMode) {
        Navigator.pop(context, true);
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteManager.studHome,
          (r) => false,
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
      backgroundColor: _kBg,
      body: Consumer<StudentViewModel>(
        builder: (context, vm, _) => Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1a1363), Color(0xFF2d2a9e)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 52, 16, 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEditMode
                            ? 'Edit Application'
                            : 'Apply for Student Assistant',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        'Fill in all required fields below',
                        style: TextStyle(
                          color: Color(0x8CFFFFFF),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      // Personal Info
                      _sectionCard(
                        icon: Icons.person_outline,
                        title: 'Personal Information',
                        child: _styledDropdown<int>(
                          label: 'Current Year of Study',
                          value: vm.yearOfStudy,
                          items: [1, 2, 3],
                          itemLabel: (y) => 'Year $y',
                          onChanged: vm.setYearOfStudy,
                          validator: vm.validateYearOfStudy,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // First Course
                      _sectionCard(
                        icon: Icons.menu_book_outlined,
                        title: 'First Course Selection',
                        subtitle: 'Select the course you wish to assist with',
                        child: _styledDropdown<String>(
                          label: 'Course 1',
                          value: vm.module1,
                          items: _courses,
                          itemLabel: (c) => c,
                          onChanged: vm.setModule1,
                          validator: vm.validateModule1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Second Course
                      _card(
                        child: Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            leading: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.add_circle_outline,
                                color: _kPrimary,
                                size: 16,
                              ),
                            ),
                            title: const Text(
                              'Second Module Selection',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            subtitle: const Text(
                              'Optional · Maximum 2 modules per application',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            initiallyExpanded:
                                _isEditMode &&
                                widget.applicationToEdit?.secondModule != null,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                                child: _styledDropdown<String>(
                                  label: 'Course 2',
                                  value: vm.module2,
                                  items: _courses
                                      .where((c) => c != vm.module1)
                                      .toList(),
                                  itemLabel: (c) => c,
                                  nullable: true,
                                  onChanged: vm.setModule2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Eligibility
                      _sectionCard(
                        icon: Icons.check_circle_outline,
                        title: 'Eligibility & Documentation',
                        subtitle: 'Must not be currently appointed at CUT',
                        child: Column(
                          children: [
                            FormField<bool>(
                              initialValue: vm.eligibilityConfirmed,
                              validator: vm.validateEligibility,
                              builder: (field) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: CheckboxListTile(
                                      value: field.value ?? false,
                                      title: const Text(
                                        'I confirm I meet all minimum requirements',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        field.didChange(val);
                                        vm.setEligibilityConfirmed(
                                          val ?? false,
                                        );
                                      },
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      activeColor: _kPrimary,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                      dense: true,
                                    ),
                                  ),
                                  if (field.errorText != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 4,
                                        left: 8,
                                      ),
                                      child: Text(
                                        field.errorText!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Upload button
                            GestureDetector(
                              onTap: () => vm.pickDocument(),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: vm.supportingDocument != null
                                      ? const Color(0xFFD1FAE5)
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: vm.supportingDocument != null
                                        ? const Color(0xFF6EE7B7)
                                        : const Color(0xFFE2E8F0),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      vm.supportingDocument != null
                                          ? Icons.check_circle
                                          : Icons.upload_file_outlined,
                                      color: vm.supportingDocument != null
                                          ? const Color(0xFF065F46)
                                          : _kPrimary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        vm.supportingDocument != null
                                            ? 'Document selected ✓'
                                            : _isEditMode
                                            ? 'Replace Supporting Document (PDF)'
                                            : 'Upload Supporting Document (PDF)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: vm.supportingDocument != null
                                              ? const Color(0xFF065F46)
                                              : _kPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Upload one PDF: CV, certified ID, Grade 12 certificate, academic record, proof of registration, and cover letter.',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (vm.errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Text(
                            vm.errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFF991B1B),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: vm.isLoading ? null : () => _submit(vm),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: vm.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _isEditMode
                                      ? 'Save Changes'
                                      : 'Submit Application',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.04 * 255).round()),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return _card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: _kPrimary, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFE2E8F0), height: 1),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _styledDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
    bool nullable = false,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        labelStyle: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kPrimary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        isDense: true,
      ),
      style: const TextStyle(
        fontSize: 13,
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w500,
      ),
      items: [
        if (nullable)
          DropdownMenuItem<T>(value: null, child: const Text('None')),
        ...items.map(
          (i) => DropdownMenuItem<T>(value: i, child: Text(itemLabel(i))),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
