class RegisterRetrieveModel {
  String username;
  String password;
  String name;
  String Lastname;
  String email;
  String DOB;
  String contact;
  String status;       // Still used for "verified"/"unverified"
  String? bedStatus;   // NEW FIELD: "allocated" / "unallocated"
  String? key;

  RegisterRetrieveModel({
    required this.username,
    required this.password,
    required this.name,
    required this.Lastname,
    required this.email,
    required this.DOB,
    required this.contact,
    required this.status,
    this.bedStatus,
    this.key,
  });

  factory RegisterRetrieveModel.fromJson(Map<dynamic, dynamic> json, String key) {
    return RegisterRetrieveModel(
      username: json['Username'] ?? '',
      password: json['Password'] ?? '',
      name: json['FirstName'] ?? '',
      Lastname: json['LastName'] ?? '',
      email: json['Email'] ?? '',
      DOB: json['DOB'] ?? '',
      contact: json['ContactNumber'] ?? '',
      status: json['Status'] ?? '',
      bedStatus: json['BedStatus'],  // can be null initially
      key: key,
    );
  }
}
