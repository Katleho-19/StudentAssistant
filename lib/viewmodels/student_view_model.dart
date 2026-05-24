import 'dart:io';
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
  File? _supportingDocument;
  bool _eligibilityConfirmed = false;

  // Status
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  int? get yearOfStudy => _yearOfStudy;
  String? get module1 => _firstModule;
  String? get module2 => _secondModule;
  File? get supportingDocument => _supportingDocument;
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

  void setSupportingDocument(File? file) {
    _supportingDocument = file;
    notifyListeners();
  }

  void setEligibilityConfirmed(bool confirmed) {
    _eligibilityConfirmed = confirmed;
    notifyListeners();
  }

  // Validation
  String? validateYearOfStudy(int? year) {
    if (year == null) {
      return 'Please select your year of study.';
    }
    return null;
  }

  String? validateModule1(String? module) {
    if (module == null || module.isEmpty) {
      return 'Please select your first course.';
    }
    return null;
  }

  String? validateEligibility(bool? confirmed) {
    if (confirmed == null || !confirmed) {
      return 'You must confirm eligibility.';
    }
    return null;
  }

  // Pre-fill form for edit mode
  void loadFromApplication(ApplicationModel app) {
    _yearOfStudy = app.yearOfStudy;
    _firstModule = app.firstModule;
    _secondModule = app.secondModule;
    _eligibilityConfirmed = true;
    _supportingDocument = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Reset form
  void resetForm() {
    _yearOfStudy = null;
    _firstModule = null;
    _secondModule = null;
    _supportingDocument = null;
    _eligibilityConfirmed = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Pick document from device
  Future<void> pickDocument() async {
    final file = await _repository.pickStudentDocs();
    if (file != null) {
      _supportingDocument = file;
      notifyListeners();
    }
  }

  // Load student data from Learners table
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

      final app = await _repository.fetchMyApplication();
      _application = app;

      // Always read the name from the learner row - it is inserted at
      // registration so it exists even before an application is submitted.
      if (app != null) {
        firstName = app.firstName ?? '';
        surname = app.surname ?? '';
      } else {
        // Fallback: fetch profile row directly (name columns only)
        final profile = await Supabase.instance.client
            .from('learner')
            .select('"First Name", "Surname"')
            .eq('user_id', user.id)
            .maybeSingle();
        if (profile != null) {
          firstName = profile['First Name']?.toString() ?? '';
          surname = profile['Surname']?.toString() ?? '';
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
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

      // Upload document if picked (optional — failure warns but does not block)
      String? photoUrl;
      if (_supportingDocument != null) {
        try {
          photoUrl = await _repository.uploadStudentDocs(
            user.id,
            _supportingDocument!,
          );
        } catch (uploadError) {
          // Surface the real Supabase error. Common causes: bucket 'student-bucket'
          // does not exist, RLS policy blocks the upload, or bucket is not public.
          _errorMessage =
              'Document upload failed: $uploadError\nYour application will still be submitted without the document.';
          notifyListeners();
          // photoUrl stays null — submission continues without the document.
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
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
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
      if (_supportingDocument != null) {
        photoUrl = await _repository.uploadStudentDocs(
          userId,
          _supportingDocument!,
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
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //Delete- remove application
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
