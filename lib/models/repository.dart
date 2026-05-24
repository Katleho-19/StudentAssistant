import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:student_assistant/models/application_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Repository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String bucketName = 'student-bucket';

  // ── LEARNERS ──────────────────────────────────────────────────────────────

  // READ — fetch current student's record from Learners
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
      return ApplicationModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // READ — fetch all learners who have submitted (admin only)
  Future<List<ApplicationModel>> fetchAllApplications() async {
    try {
      final response = await _supabase
          .from('learner')
          .select()
          .not('firstmodule', 'is', null)
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => ApplicationModel.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // CHECK — has this student already submitted?
  Future<bool> studentHasApplication(String userId) async {
    try {
      final response = await _supabase
          .from('learner')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      return response != null && response['firstmodule'] != null;
    } catch (e) {
      return false;
    }
  }

  // CREATE — insert new student application into Learners
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
    // The learner row already exists (created at registration).
    // We UPDATE the application fields on that row instead of inserting a new one.
    // This avoids needing a unique constraint for upsert.
    final existing = await _supabase
        .from('learner')
        .select('user_id')
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      await _supabase
          .from('learner')
          .update({
            'First Name': firstName,
            'Surname': surname,
            'studentEmail': studentEmail,
            'yearOfStudy': yearOfStudy,
            'firstmodule': firstModule,
            'secondmodule': secondModule,
            'photo': photoUrl,
            'application_status': 'pending',
          })
          .eq('user_id', userId);
    } else {
      await _supabase.from('learner').insert({
        'user_id': userId,
        'First Name': firstName,
        'Surname': surname,
        'studentEmail': studentEmail,
        'yearOfStudy': yearOfStudy,
        'firstmodule': firstModule,
        'secondmodule': secondModule,
        'photo': photoUrl,
        'application_status': 'pending',
      });
    }
    return true;
  }

  // UPDATE — edit pending application fields
  Future<bool> updateApplication({
    required String userId,
    int? yearOfStudy,
    String? firstModule,
    String? secondModule,
    String? photoUrl,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      if (yearOfStudy != null) updates['yearOfStudy'] = yearOfStudy;
      if (firstModule != null) updates['firstmodule'] = firstModule;
      updates['secondmodule'] = secondModule;
      if (photoUrl != null) updates['photo'] = photoUrl;

      await _supabase.from('learner').update(updates).eq('user_id', userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // UPDATE — admin approves or rejects (updates application_status on Learners)
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
      return false;
    }
  }

  // DELETE — clear application fields (keeps student profile)
  Future<bool> deleteApplication(String userId) async {
    try {
      await _supabase.from('learner').delete().eq('user_id', userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── DOCUMENT STORAGE ──────────────────────────────────────────────────────

  // Pick PDF from device
  Future<File?> pickStudentDocs() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  // Upload document and return public URL
  Future<String?> uploadStudentDocs(String userId, File file) async {
    final ext = file.path.split('.').last.toLowerCase();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final path = '$userId/$fileName';

    // Let exceptions propagate so the caller can surface the real error.
    await _supabase.storage
        .from(bucketName)
        .upload(path, file, fileOptions: const FileOptions(upsert: true));

    return _supabase.storage.from(bucketName).getPublicUrl(path);
  }

  // Delete document from storage
  Future<void> deleteStudentDocs(String filePath) async {
    try {
      await _supabase.storage.from(bucketName).remove([filePath]);
    } catch (e) {
      return;
    }
  }
}
