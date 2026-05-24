//please do not touch!!!
class Admin {
  String? userId;
  String? email;
  String? firstName;
  String? surname;
  String? password;
  String? status;

  Admin({
    this.userId,
    this.email, 
    this.firstName, 
    this.surname, 
    this.password, 
    this.status
    });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      userId: json['user_id'],
      email: json['AdminEmail'],
      firstName: json['FirstName'],
      surname: json['Surname'],
      password: json['password'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'AdminEmail': email,
      'FirstName': firstName,
      'Surname': surname,
      'password': password,
      'status': status,
    };
  }
}
