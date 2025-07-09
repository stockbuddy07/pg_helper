import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pg_helper/register.dart';
import 'package:pg_helper/saveSharePreferences.dart';
import 'package:pg_helper/userPassswordChangeUserName.dart';
import 'AdminHomePage.dart';
import 'BottomNavigation.dart';

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
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // Logo and Welcome Section
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.home_work_outlined,
                          size: 40,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'StayMate',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your Perfect PG Companion',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Login Form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Username Field
                          TextFormField(
                            controller: controlleruname,
                            validator: (value) =>
                            value!.isEmpty ? 'Please enter username' : null,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              labelStyle: const TextStyle(color: Colors.grey),
                              prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            controller: controllerpassword,
                            obscureText: !isPasswordVisible,
                            validator: (value) =>
                            value!.isEmpty ? 'Please enter password' : null,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(color: Colors.grey),
                              prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
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
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _performLogin(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign Up Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Registration()),
                          );
                        },
                        child: const Text(
                          "Sign up",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _performLogin(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

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
          await saveData('isLoggedIn', 'true');

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

    setState(() {
      isLoading = false;
    });

    if (!loginSuccess) {
      _showDialog(context, "Login Failed", msg);
    }
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
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