
class RegisterRetrieveModel {
  String? key; // Firebase key
  String username;
  String password;
  String name;
  String Lastname;
  String email;
  String DOB;
  String contact;
  String status;

  RegisterRetrieveModel({
    this.key,
    required this.username,
    required this.password,
    required this.name,
    required this.Lastname,
    required this.email,
    required this.DOB,
    required this.contact,
    required this.status,
  });

  // Factory constructor to create an object from Firebase snapshot
  factory RegisterRetrieveModel.fromJson(Map<dynamic, dynamic> json, String key) {
    return RegisterRetrieveModel(
      key: key,
      username: json['Username'] ?? '',
      password: json['Password'] ?? '',
      name: json['FirstName'] ?? '',
      Lastname: json['LastName'] ?? '',
      email: json['Email'] ?? '',
      DOB: json['DOB'] ?? '',
      contact: json['ContactNumber'] ?? '',
      status: json['Status'] ?? '',
    );
  }
}
