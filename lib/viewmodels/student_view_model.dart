import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application_model.dart';
import '../models/repository.dart';
import '../routes/route_manager.dart';
import '../feature/auth/auth_service.dart';

class StudentViewModel extends ChangeNotifier {
  final Repository _repository;
  final AuthService _authService = AuthService();

  StudentViewModel(this._repository) {
    loadStudentData();
  }

  // Profile
  String firstName = '';
  String surname = '';
  String studentEmail = '';

  // Current application
  ApplicationModel? _application;
  ApplicationModel? get application => _application;

  // Form fields
  int? _yearOfStudy;
  String? _firstModule;
  String? _secondModule;

  // File upload — bytes based (web compatible)
  Uint8List? _docBytes;
  String? _docFileName;

  bool _eligibilityConfirmed = false;

  // Status
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  int? get yearOfStudy => _yearOfStudy;
  String? get module1 => _firstModule;
  String? get module2 => _secondModule;
  Uint8List? get docBytes => _docBytes;
  String? get docFileName => _docFileName;
  bool get eligibilityConfirmed => _eligibilityConfirmed;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Setters
  void setYearOfStudy(int? year) {
    _yearOfStudy = year;
    notifyListeners();
  }

  void setModule1(String? module) {
    _firstModule = module;
    notifyListeners();
  }

  void setModule2(String? module) {
    _secondModule = module;
    notifyListeners();
  }

  void setEligibilityConfirmed(bool confirmed) {
    _eligibilityConfirmed = confirmed;
    notifyListeners();
  }

  // Validation
  String? validateYearOfStudy(int? year) {
    if (year == null) return 'Please select your year of study.';
    return null;
  }

  String? validateModule1(String? module) {
    if (module == null || module.isEmpty)
      return 'Please select your first course.';
    return null;
  }

  String? validateEligibility(bool? confirmed) {
    if (confirmed == null || !confirmed) return 'You must confirm eligibility.';
    return null;
  }

  // Pre-fill form for edit mode
  void loadFromApplication(ApplicationModel app) {
    _yearOfStudy = app.yearOfStudy;
    _firstModule = app.firstModule;
    _secondModule = app.secondModule;
    _eligibilityConfirmed = true;
    _docBytes = null;
    _docFileName = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Reset form
  void resetForm() {
    _yearOfStudy = null;
    _firstModule = null;
    _secondModule = null;
    _docBytes = null;
    _docFileName = null;
    _eligibilityConfirmed = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Pick document from device (web-compatible — uses bytes)
  Future<void> pickDocument() async {
    final result = await _repository.pickStudentDocs();
    if (result != null) {
      _docBytes = result['bytes'] as Uint8List;
      _docFileName = result['name'] as String;
      notifyListeners();
    }
  }

  // Load student data — profile name comes from learner row (set at registration)
  Future<void> loadStudentData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      studentEmail = user.email ?? '';

      // Load name from profile (exists even before application submitted)
      final profile = await _repository.fetchStudentProfile();
      if (profile != null) {
        firstName = profile['First Name']?.toString() ?? '';
        surname = profile['Surname']?.toString() ?? '';
      }

      // Load application (only set if firstmodule is filled)
      final app = await _repository.fetchMyApplication();
      _application = app;
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
      debugPrint('loadStudentData error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // CREATE — submit new application
  Future<bool> submitApplication() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (_yearOfStudy == null ||
        _firstModule == null ||
        !_eligibilityConfirmed) {
      _errorMessage =
          'Please fill in all required fields and confirm eligibility.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        _errorMessage = 'User not authenticated.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check for existing application
      if (await _repository.studentHasApplication(user.id)) {
        _errorMessage = 'You have already submitted an application.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Upload document if picked
      String? photoUrl;
      if (_docBytes != null && _docFileName != null) {
        photoUrl = await _repository.uploadStudentDocs(
          user.id,
          _docBytes!,
          _docFileName!,
        );
        if (photoUrl == null) {
          _errorMessage =
              _repository.lastError ??
              'Document upload failed. Please try again.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      final success = await _repository.createApplication(
        userId: user.id,
        firstName: firstName,
        surname: surname,
        studentEmail: studentEmail,
        yearOfStudy: _yearOfStudy!,
        firstModule: _firstModule!,
        secondModule: _secondModule,
        photoUrl: photoUrl,
      );

      if (success) {
        await loadStudentData();
      } else {
        _errorMessage =
            _repository.lastError ?? 'Submission failed. Please try again.';
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      debugPrint('submitApplication error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // UPDATE — edit pending application
  Future<bool> updateApplication(
    String userId, {
    int? yearOfStudy,
    String? firstModule,
    String? secondModule,
    bool? eligibilityConfirmed,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? photoUrl;
      if (_docBytes != null && _docFileName != null) {
        photoUrl = await _repository.uploadStudentDocs(
          userId,
          _docBytes!,
          _docFileName!,
        );
      }

      final success = await _repository.updateApplication(
        userId: userId,
        yearOfStudy: yearOfStudy,
        firstModule: firstModule,
        secondModule: secondModule,
        photoUrl: photoUrl,
      );

      if (success) {
        await loadStudentData();
      } else {
        _errorMessage = 'Update failed. Please try again.';
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      debugPrint('updateApplication error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // DELETE — remove application
  Future<bool> deleteApplication(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _repository.deleteApplication(userId);
      if (success) {
        _application = null;
      } else {
        _errorMessage = 'Delete failed. Please try again.';
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      debugPrint('deleteApplication error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout(BuildContext context) async {
    await _authService.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, RouteManager.login);
    }
  }
}
