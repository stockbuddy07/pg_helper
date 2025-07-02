
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Soft white background
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
                      'assets/login_back.png', // Replace with your image path
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
                        backgroundColor: const Color(0xFF007BFF), // Flat blue
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                      const Text('Log In', style: TextStyle(fontSize: 16 ,color: Colors.white)),
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

  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
    Map data;
    bool loginSuccess = false;

    await dbRef2.once().then((documentSnapshot) async {
      if (documentSnapshot.snapshot.children.isEmpty) {
        // No user found
        loginSuccess = false;
        return;
      }

      for (var x in documentSnapshot.snapshot.children) {
        String? key = x.key;
        data = x.value as Map;

        if (data["Username"] == username &&
            data["Password"].toString() == encPassword) {
          await saveData('username', data["Username"]);
          await saveData('firstname', data["FirstName"]);
          await saveData('lastname', data["LastName"]);
          await saveData('email', data["Email"]);
          await saveData('status', data["Status"]);
          await saveData('key', key);
          loginSuccess = true;

          Navigator.pop(context); // close loading or previous screen

          if (data["Email"] == "shubham@admin.com") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminHomePage(0)),
            );
          } else if (data["Status"] == "Verified") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BottomBar()),
            );
          } else {
            // If user exists but not verified
            msg = "Your account is not verified yet.";
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Account Not Verified"),
                  content: Text(msg),
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

          break; // Stop loop after successful login
        }
      }
    });

    // Show alert box only if login failed
    if (!loginSuccess) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Login Failed"),
            content: Text(msg),
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
  }


  String encryptString(String originalString) {
    var bytes = utf8.encode(originalString);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
}
