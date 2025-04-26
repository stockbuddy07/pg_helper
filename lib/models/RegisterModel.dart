// ignore_for_file: non_constant_identifier_names, file_names

class RegisterModel {
  late String username;
  late String password;
  late String name;
  late String Lastname;
  late String email;
  late String DOB;
  late String contact;
  late String status;

  RegisterModel(this.username, this.password, this.email, this.name,
      this.Lastname, this.DOB, this.contact, this.status);

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'Username': username,
    'Password': password,
    'FirstName': name,
    'LastName': Lastname,
    'Email': email,
    'DOB': DOB,
    'ContactNumber': contact,
    'Status': status
  };
}
