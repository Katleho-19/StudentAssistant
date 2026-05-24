import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_assistant/models/application_model.dart';
import 'package:student_assistant/viewmodels/student_view_model.dart';
import 'package:student_assistant/routes/route_manager.dart';

const _kPrimary = Color(0xFF1a1363);
const _kBg = Color(0xFFF1F5F9);

class ApplicationDetailScreen extends StatefulWidget {
  final ApplicationModel application;
  const ApplicationDetailScreen({super.key, required this.application});
  @override
  State<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  bool _isDeleting = false;

  Future<void> _deleteApplication() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Application'),
        content: const Text(
          'Are you sure you want to delete your application? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF991B1B),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed != true) {
      return;
    }
    setState(() {
      _isDeleting = true;
    });
    try {
      final userId = widget.application.userId;
      if (userId == null) return;
      final vm = context.read<StudentViewModel>();
      await vm.deleteApplication(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application deleted.'),
            backgroundColor: Color(0xFF065F46),
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteManager.studHome,
          (r) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    final status = app.applicationStatus.toLowerCase();
    final isPending = status == 'pending';

    Color statusBg, statusBorder, statusTextColor;
    IconData statusIcon;
    String statusLabel, statusDesc;
    if (status == 'approved') {
      statusBg = const Color(0xFFD1FAE5);
      statusBorder = const Color(0xFF6EE7B7);
      statusTextColor = const Color(0xFF065F46);
      statusIcon = Icons.check_circle_outline;
      statusLabel = 'approved';
      statusDesc = 'Your application has been approved. Congratulations!';
    } else if (status == 'rejected') {
      statusBg = const Color(0xFFFEE2E2);
      statusBorder = const Color(0xFFFCA5A5);
      statusTextColor = const Color(0xFF991B1B);
      statusIcon = Icons.cancel_outlined;
      statusLabel = 'rejected';
      statusDesc = 'Your application was not successful.';
    } else {
      statusBg = const Color(0xFFFEF3C7);
      statusBorder = const Color(0xFFFCD34D);
      statusTextColor = const Color(0xFF92400E);
      statusIcon = Icons.access_time_outlined;
      statusLabel = 'pending';
      statusDesc = 'Your application is under review. We will notify you soon.';
    }

    final name = '${app.firstName ?? ''} ${app.surname ?? ''}'.trim();
    final initials = name.length >= 2
        ? '${name[0]}${name.split(' ').last.isNotEmpty ? name.split(' ').last[0] : ''}'
              .toUpperCase()
        : name.isNotEmpty
        ? name[0].toUpperCase()
        : 'ST';

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Application',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Student Assistant Programme',
                      style: TextStyle(color: Color(0x8CFFFFFF), fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  // Profile + status card
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 23,
                              backgroundColor: const Color(0xFFEEF2FF),
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _kPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.isNotEmpty ? name : 'Student',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  app.studentEmail ?? '',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(color: Color(0xFFE2E8F0), height: 1),
                        const SizedBox(height: 14),
                        // Status
                        Container(
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: statusBorder),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                statusIcon,
                                color: statusTextColor,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      statusLabel,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: statusTextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      statusDesc,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: statusTextColor.withAlpha(
                                          (0.8 * 255).round(),
                                        ),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Details card
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'APPLICATION DETAILS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _detailRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Year of Study',
                          value: app.yearOfStudy != null
                              ? 'Year ${app.yearOfStudy}'
                              : '-',
                        ),
                        _detailRow(
                          icon: Icons.menu_book_outlined,
                          label: 'First Module',
                          value: app.firstModule ?? '-',
                        ),
                        _detailRow(
                          icon: Icons.check_circle_outline,
                          label: 'Eligibility',
                          value: 'Confirmed',
                          valueColor: const Color(0xFF065F46),
                        ),
                        _detailRow(
                          icon: Icons.attach_file,
                          label: 'Document',
                          value: app.photo != null
                              ? 'Uploaded'
                              : 'Not uploaded',
                          valueColor: app.photo != null
                              ? const Color(0xFF065F46)
                              : const Color(0xFF94A3B8),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Actions
                  if (isPending) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              RouteManager.editApplication,
                              arguments: widget.application,
                            ),
                            icon: const Icon(Icons.edit_outlined, size: 15),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _kPrimary,
                              side: const BorderSide(
                                color: _kPrimary,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: _isDeleting ? null : _deleteApplication,
                          icon: _isDeleting
                              ? const SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                  size: 15,
                                ),
                          label: Text(
                            _isDeleting ? 'Deleting...' : 'Delete',
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF991B1B),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ] else if (status == 'rejected') ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isDeleting ? null : _deleteApplication,
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 16,
                        ),
                        label: const Text(
                          'Delete & Reapply',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            color: Colors.grey,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'This application has been reviewed and can no longer be edited.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
