import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_assistant/models/application_model.dart';
import 'package:student_assistant/viewmodels/admin_view_model.dart';

const _kDark = Color(0xFF0F172A);
const _kBg = Color(0xFFF1F5F9);

class AdminView extends StatefulWidget {
  const AdminView({super.key});
  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().fetchAllApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminViewModel>(
      builder: (context, vm, _) => Scaffold(
        backgroundColor: _kBg,
        body: Column(
          children: [
            // Dark header
            Container(
              color: _kDark,
              padding: const EdgeInsets.fromLTRB(18, 50, 18, 14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Portal',
                            style: TextStyle(
                              color: Color(0x73FFFFFF),
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Applications',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => vm.logout(context),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha((0.08 * 255).round()),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.logout,
                            color: Color(0x80FFFFFF),
                            size: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Stat boxes
                  Row(
                    children: [
                      _StatBox(
                        label: 'Pending',
                        count: vm.pendingCount,
                        textColor: const Color(0xFFFBBF24),
                        bg: const Color(0xFF261F0A),
                        border: const Color(0xFF4D3800),
                      ),
                      const SizedBox(width: 8),
                      _StatBox(
                        label: 'Approved',
                        count: vm.approvedCount,
                        textColor: const Color(0xFF34D399),
                        bg: const Color(0xFF062015),
                        border: const Color(0xFF0A4030),
                      ),
                      const SizedBox(width: 8),
                      _StatBox(
                        label: 'Rejected',
                        count: vm.rejectedCount,
                        textColor: const Color(0xFFF87171),
                        bg: const Color(0xFF200A0A),
                        border: const Color(0xFF4D0000),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Filter chips
            Container(
              color: _kBg,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['all', 'pending', 'approved', 'rejected'].map((f) {
                    final active = vm.statusFilter == f;
                    return GestureDetector(
                      onTap: () => vm.setStatusFilter(f),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: active ? const Color(0xFF1a1363) : _kBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active
                                ? const Color(0xFF1a1363)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          f[0].toUpperCase() + f.substring(1),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: active
                                ? Colors.white
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            // Messages
            if (vm.errorMessage != null)
              Container(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
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
            if (vm.successMessage != null)
              Container(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF6EE7B7)),
                ),
                child: Text(
                  vm.successMessage!,
                  style: const TextStyle(
                    color: Color(0xFF065F46),
                    fontSize: 12,
                  ),
                ),
              ),
            // List
            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.applications.isEmpty
                  ? Center(
                      child: Text(
                        'No ${vm.statusFilter == 'all' ? '' : vm.statusFilter} applications found.',
                        style: const TextStyle(color: Color(0xFF94A3B8)),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: vm.fetchAllApplications,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
                        itemCount: vm.applications.length,
                        itemBuilder: (ctx, i) {
                          final app = vm.applications[i];
                          return _AppCard(
                            app: app,
                            onApprove: app.applicationStatus == 'pending'
                                ? () => vm.approveApplication(app.id!)
                                : null,
                            onReject: app.applicationStatus == 'pending'
                                ? () => _confirmReject(ctx, vm, app)
                                : null,
                            onDelete: () => _confirmDelete(ctx, vm, app),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmReject(
  BuildContext context,
  AdminViewModel vm,
  ApplicationModel app,
) async {
  final ok = await vm.showConfirmationDialog(
    context,
    title: 'Reject Application',
    content: 'Are you sure you want to reject this application?',
    confirmLabel: 'Reject',
    confirmColor: const Color(0xFF991B1B),
  );
  if (ok) vm.rejectApplication(app.id!);
}

Future<void> _confirmDelete(
  BuildContext context,
  AdminViewModel vm,
  ApplicationModel app,
) async {
  final ok = await vm.showConfirmationDialog(
    context,
    title: 'Remove Application',
    content: 'Permanently remove this application?',
    confirmLabel: 'Remove',
    confirmColor: const Color(0xFF991B1B),
  );
  if (ok) vm.deleteApplication(app.id!);
}

class _AppCard extends StatelessWidget {
  final ApplicationModel app;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback onDelete;
  const _AppCard({
    required this.app,
    this.onApprove,
    this.onReject,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final status = app.applicationStatus.toLowerCase();
    Color badgeBg, badgeBorder, badgeText, avatarBg, avatarText;
    if (status == 'approved') {
      badgeBg = const Color(0xFFD1FAE5);
      badgeBorder = const Color(0xFF6EE7B7);
      badgeText = const Color(0xFF065F46);
      avatarBg = const Color(0xFFD1FAE5);
      avatarText = const Color(0xFF065F46);
    } else if (status == 'rejected') {
      badgeBg = const Color(0xFFFEE2E2);
      badgeBorder = const Color(0xFFFCA5A5);
      badgeText = const Color(0xFF991B1B);
      avatarBg = const Color(0xFFFEE2E2);
      avatarText = const Color(0xFF991B1B);
    } else {
      badgeBg = const Color(0xFFFEF3C7);
      badgeBorder = const Color(0xFFFCD34D);
      badgeText = const Color(0xFF92400E);
      avatarBg = const Color(0xFFEEF2FF);
      avatarText = const Color(0xFF3730A3);
    }

    final name = '${app.firstName ?? ''} ${app.surname ?? ''}'.trim();
    final initials = name.length >= 2
        ? '${name[0]}${name.split(' ').last.isNotEmpty ? name.split(' ').last[0] : ''}'
              .toUpperCase()
        : name.isNotEmpty
        ? name[0].toUpperCase()
        : '??';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.03 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 19,
                backgroundColor: avatarBg,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: avatarText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty ? name : 'Unknown',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '${app.studentEmail ?? ''} · Year ${app.yearOfStudy ?? '-'}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: badgeBorder),
                ),
                child: Text(
                  app.applicationStatus[0].toUpperCase() +
                      app.applicationStatus.substring(1),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: badgeText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            app.firstModule ?? '-',
            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),
          if (status == 'pending') ...[
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onApprove,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, size: 12, color: Color(0xFF065F46)),
                          SizedBox(width: 4),
                          Text(
                            'Approve',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF065F46),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: onReject,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close, size: 12, color: Color(0xFF991B1B)),
                          SizedBox(width: 4),
                          Text(
                            'Reject',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF991B1B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: onDelete,
                  child: const Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 14,
                        color: Color(0xFF94A3B8),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Remove',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final int count;
  final Color textColor, bg, border;
  const _StatBox({
    required this.label,
    required this.count,
    required this.textColor,
    required this.bg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: textColor.withAlpha((0.8 * 255).round()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
