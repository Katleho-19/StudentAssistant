import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application_model.dart';
import '../routes/route_manager.dart';
import '../feature/auth/auth_service.dart';

class AdminViewModel extends ChangeNotifier {
  final SupabaseClient _supabase;
  final AuthService _authService = AuthService();

  AdminViewModel(this._supabase);

  List<ApplicationModel> _applications = [];
  List<ApplicationModel> _filtered = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String _statusFilter = 'all';

  List<ApplicationModel> get applications => _filtered;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String get statusFilter => _statusFilter;

  int get totalCount => _applications.length;
  int get pendingCount =>
      _applications.where((a) => a.applicationStatus == 'pending').length;
  int get approvedCount =>
      _applications.where((a) => a.applicationStatus == 'approved').length;
  int get rejectedCount =>
      _applications.where((a) => a.applicationStatus == 'rejected').length;

  void _applyFilter() {
    _filtered = _statusFilter == 'all'
        ? List.from(_applications)
        : _applications
              .where((a) => a.applicationStatus == _statusFilter)
              .toList();
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    _applyFilter();
  }

  // READ — fetch all student applications from Learners
  Future<void> fetchAllApplications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('learner')
          .select()
          .not('firstmodule', 'is', null)
          .order('created_at', ascending: false);

      _applications = (response as List)
          .map((e) => ApplicationModel.fromJson(e))
          .toList();
      _applyFilter();
    } on PostgrestException catch (e) {
      _errorMessage = 'Failed to load applications: ${e.message}';
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // UPDATE — approve or reject (updates application_status on learner)
  Future<bool> updateApplicationStatus(int id, String newStatus) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabase
          .from('learner')
          .update({'application_status': newStatus})
          .eq('id', id);

      final index = _applications.indexWhere((a) => a.id == id);
      if (index != -1) {
        _applications[index] = _applications[index].copyWith(
          applicationStatus: newStatus,
        );
        _applyFilter();
      }

      _successMessage =
          'Application ${newStatus == 'approved' ? 'approved' : 'rejected'}.';
      _errorMessage = null;
      notifyListeners();
      return true;
    } on PostgrestException catch (e) {
      _errorMessage = 'Failed to update: ${e.message}';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveApplication(int id) =>
      updateApplicationStatus(id, 'approved');

  Future<bool> rejectApplication(int id) =>
      updateApplicationStatus(id, 'rejected');

  // DELETE — clear application fields on learner
  Future<bool> deleteApplication(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabase
          .from('learner')
          .update({
            'yearOfStudy': null,
            'firstmodule': null,
            'secondmodule': null,
            'photo': null,
            'application_status': null,
          })
          .eq('id', id);

      _applications.removeWhere((a) => a.id == id);
      _applyFilter();
      _successMessage = 'Application removed.';
      _errorMessage = null;
      notifyListeners();
      return true;
    } on PostgrestException catch (e) {
      _errorMessage = 'Failed to delete: ${e.message}';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout(BuildContext context) async {
    await _authService.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, RouteManager.login);
    }
  }

  // Confirmation dialog
  Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmLabel = 'Confirm',
    Color confirmColor = Colors.red,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: confirmColor),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}
