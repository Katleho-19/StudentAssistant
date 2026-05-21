import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:student_assistant/models/application_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Repository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String bucketName = 'student-bucket';
  String? lastError;

  // ── LEARNERS ──────────────────────────────────────────────────────────────

  // READ — fetch current student's record from learner table
  Future<ApplicationModel?> fetchMyApplication() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('learner')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;

      final app = ApplicationModel.fromJson(response);
      if (app.firstModule == null &&
          app.applicationStatus == null &&
          app.photo == null) {
        return null;
      }

      return app;
    } catch (e) {
      debugPrint('fetchMyApplication error: $e');
      return null;
    }
  }

  // READ — fetch student profile (name/email) even before application submitted
  Future<Map<String, dynamic>?> fetchStudentProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('learner')
          .select('First Name, Surname, studentEmail')
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('fetchStudentProfile error: $e');
      return null;
    }
  }

  // READ — fetch all learners who have submitted (admin only)
  Future<List<ApplicationModel>> fetchAllApplications() async {
    try {
      final response = await _supabase
          .from('learner')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => ApplicationModel.fromJson(e))
          .where(
            (app) =>
                app.firstModule != null ||
                app.secondModule != null ||
                app.applicationStatus != null ||
                app.photo != null,
          )
          .toList();
    } catch (e) {
      debugPrint('fetchAllApplications error: $e');
      return [];
    }
  }

  // CHECK — has this student already submitted?
  Future<bool> studentHasApplication(String userId) async {
    try {
      final response = await _supabase
          .from('learner')
          .select('firstmodule, application_status, photo')
          .eq('user_id', userId)
          .maybeSingle();
      if (response == null) return false;
      return response['firstmodule'] != null ||
          response['application_status'] != null ||
          response['photo'] != null;
    } catch (e) {
      debugPrint('studentHasApplication error: $e');
      return false;
    }
  }

  // CREATE — insert new student application into learner table
  Future<bool> createApplication({
    required String userId,
    required String firstName,
    required String surname,
    required String studentEmail,
    required int yearOfStudy,
    required String firstModule,
    String? secondModule,
    String? photoUrl,
  }) async {
    lastError = null;
    try {
      final existing = await _supabase
          .from('learner')
          .select('user_id')
          .eq('user_id', userId)
          .maybeSingle();

      final payload = {
        'user_id': userId,
        'First Name': firstName,
        'Surname': surname,
        'studentEmail': studentEmail,
        'yearOfStudy': yearOfStudy,
        'firstmodule': firstModule,
        'secondmodule': secondModule,
        'photo': photoUrl,
        'application_status': 'pending',
      };

      if (existing == null) {
        await _supabase.from('learner').insert(payload);
      } else {
        await _supabase.from('learner').update(payload).eq('user_id', userId);
      }

      return true;
    } on PostgrestException catch (e) {
      lastError = e.message;
      debugPrint('createApplication error: ${e.message}');
      return false;
    } catch (e) {
      lastError = e.toString();
      debugPrint('createApplication error: $e');
      return false;
    }
  }

  // UPDATE — edit pending application fields
  Future<bool> updateApplication({
    required String userId,
    int? yearOfStudy,
    String? firstModule,
    String? secondModule,
    String? photoUrl,
  }) async {
    lastError = null;
    try {
      final Map<String, dynamic> updates = {};
      if (yearOfStudy != null) updates['yearOfStudy'] = yearOfStudy;
      if (firstModule != null) updates['firstmodule'] = firstModule;
      updates['secondmodule'] = secondModule;
      if (photoUrl != null) updates['photo'] = photoUrl;

      await _supabase.from('learner').update(updates).eq('user_id', userId);
      return true;
    } on PostgrestException catch (e) {
      lastError = e.message;
      debugPrint('updateApplication error: ${e.message}');
      return false;
    } catch (e) {
      lastError = e.toString();
      debugPrint('updateApplication error: $e');
      return false;
    }
  }

  // UPDATE — admin approves or rejects
  Future<bool> updateApplicationStatus({
    required String userId,
    required String newStatus,
  }) async {
    try {
      await _supabase
          .from('learner')
          .update({'application_status': newStatus})
          .eq('user_id', userId);
      return true;
    } catch (e) {
      debugPrint('updateApplicationStatus error: $e');
      return false;
    }
  }

  // DELETE — clear application fields (keeps student profile)
  Future<bool> deleteApplication(String userId) async {
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
          .eq('user_id', userId);
      return true;
    } catch (e) {
      debugPrint('deleteApplication error: $e');
      return false;
    }
  }

  // ── DOCUMENT STORAGE ──────────────────────────────────────────────────────

  // Pick file — returns bytes + filename (works on Web, Android, iOS, Desktop)
  Future<Map<String, dynamic>?> pickStudentDocs() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        withData: true, // Forces bytes into memory — required for web
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null) return null;

      return {'bytes': bytes, 'name': file.name};
    } catch (e) {
      debugPrint('pickStudentDocs error: $e');
      return null;
    }
  }

  // Upload document bytes and return public URL
  Future<String?> uploadStudentDocs(
    String userId,
    Uint8List bytes,
    String fileName,
  ) async {
    lastError = null;
    try {
      final ext = fileName.contains('.') ? fileName.split('.').last : 'pdf';
      final storageName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final path = '$userId/$storageName';

      await _supabase.storage
          .from(bucketName)
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      return _supabase.storage.from(bucketName).getPublicUrl(path);
    } on PostgrestException catch (e) {
      lastError = e.message;
      debugPrint('uploadStudentDocs error: ${e.message}');
      return null;
    } catch (e) {
      lastError = e.toString();
      debugPrint('uploadStudentDocs error: $e');
      return null;
    }
  }

  // Delete document from storage
  Future<void> deleteStudentDocs(String filePath) async {
    try {
      await _supabase.storage.from(bucketName).remove([filePath]);
    } catch (e) {
      debugPrint('deleteStudentDocs error: $e');
    }
  }
}
