class ApplicationModel {
  String? id;
  String? userId;
  String? firstName;
  String? surname;
  String? studentEmail;
  int? yearOfStudy;
  String? firstModule;
  String? secondModule;
  bool? eligibilityConfirmed;
  String? photo;
  String? applicationStatus;
  String? createdAt;

  ApplicationModel({
    this.id,
    this.userId,
    this.firstName,
    this.surname,
    this.studentEmail,
    this.yearOfStudy,
    this.firstModule,
    this.secondModule,
    this.eligibilityConfirmed,
    this.photo,
    this.applicationStatus,
    this.createdAt,
  });

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) return value.toString();
    }
    return null;
  }

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: _readString(json, ['id']),
      userId: _readString(json, ['user_id', 'userId']),
      firstName: _readString(json, ['First Name', 'FirstName', 'firstName']),
      surname: _readString(json, ['Surname', 'surname']),
      studentEmail: _readString(json, [
        'studentEmail',
        'studentemail',
        'email',
        'student_email',
      ]),
      yearOfStudy: json['yearOfStudy'] is int
          ? json['yearOfStudy'] as int
          : int.tryParse(
              _readString(json, ['yearOfStudy', 'year_of_study']) ?? '',
            ),
      firstModule: _readString(json, [
        'firstmodule',
        'firstModule',
        'First Module',
      ]),
      secondModule: _readString(json, [
        'secondmodule',
        'secondModule',
        'Second Module',
      ]),
      eligibilityConfirmed:
          json['eligibility_confirmed'] == true ||
          _readString(json, ['eligibility_confirmed'])?.toLowerCase() == 'true',
      photo: _readString(json, ['photo', 'photo_url', 'document_url']),
      applicationStatus: _readString(json, [
        'application_status',
        'status',
        'applicationStatus',
      ]),
      createdAt: _readString(json, ['created_at', 'createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'First Name': firstName,
      'Surname': surname,
      'studentEmail': studentEmail,
      'yearOfStudy': yearOfStudy,
      'firstmodule': firstModule,
      'secondmodule': secondModule,
      'eligibility_confirmed': eligibilityConfirmed,
      'photo': photo,
      'application_status': applicationStatus,
      'created_at': createdAt,
    };
  }

  ApplicationModel copyWith({
    String? id,
    String? userId,
    String? firstName,
    String? surname,
    String? studentEmail,
    int? yearOfStudy,
    String? firstModule,
    String? secondModule,
    bool? eligibilityConfirmed,
    String? photo,
    String? applicationStatus,
    String? createdAt,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      surname: surname ?? this.surname,
      studentEmail: studentEmail ?? this.studentEmail,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      firstModule: firstModule ?? this.firstModule,
      secondModule: secondModule ?? this.secondModule,
      eligibilityConfirmed: eligibilityConfirmed ?? this.eligibilityConfirmed,
      photo: photo ?? this.photo,
      applicationStatus: applicationStatus ?? this.applicationStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
