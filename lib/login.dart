import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pg_helper/register.dart';
import 'package:pg_helper/saveSharePreferences.dart';
import 'package:pg_helper/userPassswordChangeUserName.dart';
import 'AdminHomePage.dart';
import 'BottomNavigation.dart';

// ... (imports stay the same)
class Login extends StatefulWidget {
  const Login({super.key});
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController controlleruname = TextEditingController();
  TextEditingController controllerpassword = TextEditingController();
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'StayMate',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/login_back.png',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: controlleruname,
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter username' : null,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: controllerpassword,
                    obscureText: !isPasswordVisible,
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter password' : null,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _performLogin(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007BFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Log In',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const userPasswordChangeUserName(),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.blueGrey,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Registration()),
                      );
                    },
                    child: const Text(
                      "Don't have an account? Sign up",
                      style: TextStyle(
                        color: Colors.blueGrey,
                        decoration: TextDecoration.underline,
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

  void _performLogin(BuildContext context) async {
    var username = controlleruname.text.trim();
    var password = controllerpassword.text.trim();
    var encPassword = encryptString(password);

    Query dbRef2 = FirebaseDatabase.instance
        .ref()
        .child('PG_helper/tblUser')
        .orderByChild("Username")
        .equalTo(username);

    String msg = "Invalid Username or Password..! Please check..!!";
    bool loginSuccess = false;

    DataSnapshot snapshot = (await dbRef2.once()).snapshot;

    if (snapshot.exists) {
      for (var x in snapshot.children) {
        String? key = x.key;
        Map<dynamic, dynamic>? data = x.value as Map?;

        if (data == null) continue;

        String dbUsername = data["Username"]?.toString().trim() ?? "";
        String dbPassword = data["Password"]?.toString().trim() ?? "";
        String status = data["Status"]?.toString().trim().toLowerCase() ?? "";
        String bedStatus = data["BedStatus"]?.toString().trim().toLowerCase() ?? "";
        String email = data["Email"]?.toString().trim().toLowerCase() ?? "";

        if (dbUsername == username && dbPassword == encPassword) {
          // Save data before navigation
          await saveData('username', dbUsername);
          await saveData('firstname', data["FirstName"] ?? "");
          await saveData('lastname', data["LastName"] ?? "");
          await saveData('email', data["Email"] ?? "");
          await saveData('status', data["Status"] ?? "");
          await saveData('key', key ?? "");

          loginSuccess = true;

          // Admin check (allow login regardless of status/bedStatus)
          if (email == "shubham@admin.com") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminHomePage(0)),
            );
          }

          // User check
          else if (status == "verified") {
            if (bedStatus.isEmpty) {
              msg = "Your bed is not allocated yet. Please contact admin.";
              _showDialog(context, "Contact Admin", msg);
            } else if (bedStatus == "unallocated") {
              msg = "Your bed is not allocated yet.";
              _showDialog(context, "Bed Unallocated", msg);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BottomBar()),
              );
            }
          } else {
            msg = "Your account is not verified yet.";
            _showDialog(context, "Account Not Verified", msg);
          }

          break;
        }
      }
    }

    if (!loginSuccess) {
      _showDialog(context, "Login Failed", msg);
    }
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            OutlinedButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  String encryptString(String originalString) {
    var bytes = utf8.encode(originalString);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
}