import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_assistant/models/exceptionError.dart';
import 'package:student_assistant/routes/route_manager.dart';
import 'package:student_assistant/viewmodels/student_view_model.dart';

// Design colours
const _kPrimary = Color(0xFF1a1363);
const _kBg = Color(0xFFF1F5F9);
const _kPendingBg = Color(0xFFFEF3C7);
const _kPendingBorder = Color(0xFFFCD34D);
const _kPendingText = Color(0xFF92400E);
const _kApprovedBg = Color(0xFFD1FAE5);
const _kApprovedBorder = Color(0xFF6EE7B7);
const _kApprovedText = Color(0xFF065F46);
const _kRejectedBg = Color(0xFFFEE2E2);
const _kRejectedBorder = Color(0xFFFCA5A5);
const _kRejectedText = Color(0xFF991B1B);

class StudHomeScreen extends StatefulWidget {
  const StudHomeScreen({super.key});
  @override
  State<StudHomeScreen> createState() => _StudHomeScreenState();
}

class _StudHomeScreenState extends State<StudHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentViewModel>().loadStudentData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentViewModel>(
      builder: (context, vm, _) {
        final firstName = vm.firstName.isNotEmpty ? vm.firstName : '';
        final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'S';

        return Scaffold(
          backgroundColor: _kBg,
          body: Column(
            children: [
              // Gradient header
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1a1363), Color(0xFF2d2a9e)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(18, 52, 18, 18),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.2 * 255).round()),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            firstName.isNotEmpty
                                ? 'Hello, $firstName 👋'
                                : 'Welcome 👋',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Student Assistant Portal',
                            style: TextStyle(
                              color: Colors.white.withAlpha(
                                (0.55 * 255).round(),
                              ),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Logout
                    GestureDetector(
                      onTap: () => _logout(context),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha((0.1 * 255).round()),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.logout,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Body
              Expanded(
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : vm.errorMessage != null
                    ? _buildError(vm)
                    : vm.application == null
                    ? _buildNoApp(context, vm)
                    : _buildHasApp(context, vm),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildError(StudentViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              vm.errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: vm.loadStudentData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoApp(BuildContext context, StudentViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _iconWrap(Icons.school_outlined),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Application Status',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'No application submitted yet',
                          style: TextStyle(
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
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: Color(0xFF94A3B8),
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'No Application Found',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You haven\'t submitted an application yet.\nApply now to become a student assistant.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Info banner
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            padding: const EdgeInsets.all(12),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: _kPrimary, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You can apply for a maximum of 2 courses per application.',
                    style: TextStyle(
                      fontSize: 11,
                      color: _kPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _primaryBtn(
            label: 'Apply Now',
            icon: Icons.add,
            onTap: () =>
                Navigator.pushNamed(context, RouteManager.applicationForm).then(
                  (_) {
                    if (mounted) vm.loadStudentData();
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHasApp(BuildContext context, StudentViewModel vm) {
    final app = vm.application!;
    final status = app.applicationStatus.toLowerCase();

    Color statusBg, statusBorder, statusTextColor;
    IconData statusIcon;
    String statusLabel, statusDesc;

    if (status == 'approved') {
      statusBg = _kApprovedBg;
      statusBorder = _kApprovedBorder;
      statusTextColor = _kApprovedText;
      statusIcon = Icons.check_circle_outline;
      statusLabel = 'Approved';
      statusDesc = 'Congratulations! Your application has been approved.';
    } else if (status == 'rejected') {
      statusBg = _kRejectedBg;
      statusBorder = _kRejectedBorder;
      statusTextColor = _kRejectedText;
      statusIcon = Icons.cancel_outlined;
      statusLabel = 'Rejected';
      statusDesc = 'Your application was not successful.';
    } else {
      statusBg = _kPendingBg;
      statusBorder = _kPendingBorder;
      statusTextColor = _kPendingText;
      statusIcon = Icons.access_time_outlined;
      statusLabel = 'Pending Review';
      statusDesc = 'Your application is under review. We will notify you soon.';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _iconWrap(Icons.school_outlined),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Application Status',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          statusLabel.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            color: _kPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(color: Color(0xFFE2E8F0), height: 1),
                const SizedBox(height: 14),
                // Status pill
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
                      Icon(statusIcon, color: statusTextColor, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 12,
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
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            padding: const EdgeInsets.all(12),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: _kPrimary, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You can apply for a maximum of 2 courses per application.',
                    style: TextStyle(
                      fontSize: 11,
                      color: _kPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (status == 'rejected') ...[
            _primaryBtn(
              label: 'View Details',
              icon: Icons.info_outline,
              color: Colors.white,
              textColor: _kPrimary,
              border: _kPrimary,
              onTap: () =>
                  Navigator.pushNamed(
                    context,
                    RouteManager.applicationDetail,
                    arguments: app,
                  ).then((_) {
                    if (mounted) vm.loadStudentData();
                  }),
            ),
            const SizedBox(height: 10),
            _primaryBtn(
              label: vm.isLoading ? 'Please wait...' : 'Delete & Reapply',
              icon: Icons.refresh,
              onTap: vm.isLoading
                  ? null
                  : () async {
                      final userId = vm.application?.userId;
                      if (userId == null) {
                        return;
                      }
                      final success = await vm.deleteApplication(userId);
                      if (!mounted) {
                        return;
                      }
                      if (success) {
                        vm.loadStudentData();
                      }
                    },
            ),
          ] else
            _primaryBtn(
              label: 'View My Application',
              icon: Icons.visibility_outlined,
              onTap: () =>
                  Navigator.pushNamed(
                    context,
                    RouteManager.applicationDetail,
                    arguments: app,
                  ).then((_) {
                    if (mounted) vm.loadStudentData();
                  }),
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

  Widget _iconWrap(IconData icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: _kPrimary, size: 16),
    );
  }

  Widget _primaryBtn({
    required String label,
    required IconData icon,
    VoidCallback? onTap,
    Color? color,
    Color? textColor,
    Color? border,
  }) {
    final bg = color ?? _kPrimary;
    final fg = textColor ?? Colors.white;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: fg, size: 16),
        label: Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: border != null ? BorderSide(color: border) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    try {
      await context.read<StudentViewModel>().logout(context);
    } catch (e) {
      if (context.mounted) {
        Exceptionerror.snackBarError(context, 'Logout failed: ${e.toString()}');
      }
    }
  }
}
