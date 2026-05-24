class ApplicationModel {
  final int? id;
  final String? userId;
  final String? firstName;
  final String? surname;
  final String? studentEmail;
  final int? yearOfStudy;
  final String? firstModule;
  final String? secondModule;
  final String? photo;
  final String applicationStatus;
  final String? createdAt;

  ApplicationModel({
    required this.id,
    this.userId,
    this.firstName,
    this.surname,
    this.studentEmail,
    this.yearOfStudy,
    this.firstModule,
    this.secondModule,
    this.photo,
    this.applicationStatus = 'pending',
    this.createdAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'] as int?,
      userId: json['user_id']?.toString(),
      firstName: json['First Name']?.toString(),
      surname: json['Surname']?.toString(),
      studentEmail: json['studentEmail']?.toString(),
      yearOfStudy: json['yearOfStudy'] as int?,
      firstModule: json['firstmodule']?.toString(),
      secondModule: json['secondmodule']?.toString(),
      photo: json['photo']?.toString(),
      applicationStatus: json['application_status']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString(),
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
      'photo': photo,
      'application_status': applicationStatus,
      'created_at': createdAt,
    };
  }

  ApplicationModel copyWith({
    int? id,
    String? userId,
    String? firstName,
    String? surname,
    String? studentEmail,
    int? yearOfStudy,
    String? firstModule,
    String? secondModule,
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
      photo: photo ?? this.photo,
      applicationStatus: applicationStatus ?? this.applicationStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
