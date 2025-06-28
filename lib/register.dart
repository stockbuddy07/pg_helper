import 'package:flutter/material.dart';
// ignore_for_file: file_names, non_constant_identifier_names, library_private_types_in_public_api

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:pg_helper/login.dart';
import 'models/RegisterModel.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  _Registration createState() => _Registration();
}

class _Registration extends State<Registration> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DatabaseReference dbRef2 = FirebaseDatabase.instance.ref().child('PG_helper/tblUser');

  TextEditingController controlleruname = TextEditingController();
  TextEditingController controllerpassword = TextEditingController();
  TextEditingController controllerconfirmpassword = TextEditingController();
  TextEditingController controllername = TextEditingController();
  TextEditingController controllerLastname = TextEditingController();
  TextEditingController controllermail = TextEditingController();
  TextEditingController controllcontact = TextEditingController();
  TextEditingController controllerDateOfBirth = TextEditingController();
  var birthDate = "Select Birthdate";
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    controllerDateOfBirth = TextEditingController(text: birthDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Create your account",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // First Name
                  _buildTextField(controllername, "First Name", Icons.person),

                  // Last Name
                  _buildTextField(controllerLastname, "Last Name", Icons.person),

                  // Username
                  _buildTextField(controlleruname, "Username", Icons.account_box),

                  // Password
                  _buildPasswordField(controllerpassword, "Password", true),

                  // Confirm Password
                  _buildPasswordField(controllerconfirmpassword, "Confirm Password", false),

                  // Email
                  _buildTextField(controllermail, "Email", Icons.email, TextInputType.emailAddress),

                  // Contact
                  _buildTextField(controllcontact, "Contact Number", Icons.call, TextInputType.phone),

                  // DOB
                  GestureDetector(
                    onTap: () => _getDate(context),
                    child: AbsorbPointer(
                      child: _buildTextField(controllerDateOfBirth, "Date of Birth", Icons.date_range),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          var name = controllername.text;
                          var lastname = controllerLastname.text;
                          var password = controllerpassword.text;
                          var confirmPassword = controllerconfirmpassword.text;
                          var username = controlleruname.text;
                          var email = controllermail.text;
                          var contact = controllcontact.text;
                          var DOB = birthDate;
                          var encPassword = encryptString(password);

                          if (password == confirmPassword) {
                            RegisterModel regobj = RegisterModel(
                              username,
                              encPassword,
                              email,
                              name,
                              lastname,
                              DOB,
                              contact,
                              "Verify",
                            );
                            dbRef2.push().set(regobj.toJson());
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Login()),
                            );
                          } else {
                            const snackBar = SnackBar(
                              content: Text("Password does not match..!!"),
                              duration: Duration(seconds: 2),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Register", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Already have account
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
                      },
                      child: const Text(
                        "Already have an account? Sign in",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueAccent,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Reusable TextField
  Widget _buildTextField(
      TextEditingController controller,
      String hint,
      IconData icon, [
        TextInputType keyboardType = TextInputType.text,
      ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: "Enter your $hint",
          labelText: hint,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // Reusable Password Field
  Widget _buildPasswordField(TextEditingController controller, String hint, bool isMainPassword) {
    bool isVisible = isMainPassword ? isPasswordVisible : isConfirmPasswordVisible;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        decoration: InputDecoration(
          hintText: "Enter your $hint",
          labelText: hint,
          prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.blueAccent,
            ),
            onPressed: () {
              setState(() {
                if (isMainPassword) {
                  isPasswordVisible = !isPasswordVisible;
                } else {
                  isConfirmPasswordVisible = !isConfirmPasswordVisible;
                }
              });
            },
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Future<void> _getDate(BuildContext context) async {
    var datePicked = await DatePicker.showSimpleDatePicker(
      context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2090),
      dateFormat: "dd-MM-yyyy",
      locale: DateTimePickerLocale.en_us,
      looping: true,
    );
    setState(() {
      if (datePicked != null) {
        birthDate = "${datePicked.day}-${datePicked.month}-${datePicked.year}";
        controllerDateOfBirth = TextEditingController(text: birthDate);
      }
    });
  }
}

String encryptString(String originalString) {
  var bytes = utf8.encode(originalString); // Convert string to bytes
  var digest = sha256.convert(bytes); // Apply SHA-256 hash function
  return digest.toString(); // Return the hashed string
}
