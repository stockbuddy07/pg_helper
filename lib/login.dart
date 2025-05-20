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
      backgroundColor: const Color(0xff12d3c6),
      body: SafeArea(
        child: Stack(
          children: [
            // Centered LOGIN Text
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Colors.yellow, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Text(
                    "LOGIN",
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black38,
                          offset: Offset(2, 2),
                        ),
                      ],
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Sheet
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: controlleruname,
                          validator: (value) => value!.isEmpty ? 'Please enter username' : null,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person_outline, color: Color(0xff12d3c6)),
                            labelText: 'Username',
                            hintText: 'Enter Username',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: controllerpassword,
                          obscureText: !isPasswordVisible,
                          validator: (value) => value!.isEmpty ? 'Please enter password' : null,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock, color: Color(0xff12d3c6)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: const Color(0xff12d3c6),
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                            labelText: 'Password',
                            hintText: 'Enter Password',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const userPasswordChangeUserName()),
                              );
                            },
                            child: Text("Forgot Password?", style: TextStyle(color: Colors.grey.shade700)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _performLogin(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff12d3c6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('LOG IN', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account?", style: TextStyle(color: Colors.grey.shade700, fontSize: 15)),
                            TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const Registration()));
                              },
                              child: const Text(
                                "Register here",
                                style: TextStyle(
                                  color: Color(0xff12d3c6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
    var username = controlleruname.text;
    var password = controllerpassword.text;
    var encPassword = encryptString(password);
    Query dbRef2 = FirebaseDatabase.instance
        .ref()
        .child('PG_helper/tblUser')
        .orderByChild("Username")
        .equalTo(username);
    String msg = "Invalid Username or Password..! Please check..!!";
    Map data;
    var count = 0;
    await dbRef2.once().then((documentSnapshot) async {
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
          count = count + 1;

          Navigator.pop(context);

          if (data["Email"] == "shubham@admin.com") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminHomePage(0)),
            );
          } else if (data["Status"] == "Verified") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BottomBar()),
            );
          } else {
            count = 0;
            msg = "Sorry..! Wrong Username or Password";
            _showSnackbar(context, msg);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
            );
          }
        } else {
          msg = "Sorry..! Wrong Username or Password";
          _showSnackbar(context, msg);
        }
      }
      if (count == 0) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Alert Message"),
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
    });
  }

  String encryptString(String originalString) {
    var bytes = utf8.encode(originalString);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
}
