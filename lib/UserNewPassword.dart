// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:convert';


import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pg_helper/login.dart';
import 'package:pg_helper/saveSharePreferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'LandingPage.dart';

class UserNewPassword extends StatefulWidget {
  const UserNewPassword({super.key});

  @override
  State<UserNewPassword> createState() => _HospitalNewPasswordState();
}

class _HospitalNewPasswordState extends State<UserNewPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController controllerNewPassword = TextEditingController();
  TextEditingController controllerNewConfirmPasswordPassword =
  TextEditingController();
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  late String userKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'New Password',
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.grey,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            // If the Future is complete, show the actual UI
            return Column(
              children: [
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: controllerNewPassword,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter password';
                              }
                              return null;
                            },
                            obscureText: !isPasswordVisible,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  _togglePasswordVisibility(context);
                                },
                              ),
                              prefixIconColor: Colors.blue,
                              border: const OutlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(8)),
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              filled: true,
                              fillColor: const Color(0xffE0E3E7),
                              labelText: 'New Password',
                              hintText: 'Enter New Password',
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: controllerNewConfirmPasswordPassword,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter re-enter password';
                              }
                              return null;
                            },
                            obscureText: !isConfirmPasswordVisible,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isConfirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  _toggleConfirmPasswordVisibility(context);
                                },
                              ),
                              prefixIconColor: Colors.blue,
                              border: const OutlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(8)),
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              filled: true,
                              fillColor: const Color(0xffE0E3E7),
                              labelText: 'New Confirm Password',
                              hintText: 'Re-Enter New Password',
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                              onPressed: () async {
                                var newPassword = controllerNewPassword.text;
                                var newConfirmPassword =
                                    controllerNewConfirmPasswordPassword.text;
                                if (newPassword == newConfirmPassword) {
                                  updateData(userKey);
                                  SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                                  prefs.clear();
                                  // Navigator.pop(context);
                                  Navigator.pop(context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const Login()));
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Alert Message"),
                                        content: const Text(
                                            "Both Password must same..! Please check both passwords..!"),
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
                              },
                              child: const Text("Change Password"))
                        ],
                      ),
                    ))
              ],
            );
          }
        },
        future: _loadUserData(),
      ),
    );
  }

  void _toggleConfirmPasswordVisibility(BuildContext context) {
    setState(() {
      isConfirmPasswordVisible = !isConfirmPasswordVisible;
    });
  }

  void _togglePasswordVisibility(BuildContext context) {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  void updateData(String userkey) async {
    var encPassword = encryptString(controllerNewPassword.text);
    final updatedData = {
      "Password": encPassword,
    };

    final userRef = FirebaseDatabase.instance
        .ref()
        .child("ArogyaSair/tblUser")
        .child(userkey);
    await userRef.update(updatedData);
  }

  String encryptString(String originalString) {
    var bytes = utf8.encode(originalString); // Convert string to bytes
    var digest = sha256.convert(bytes); // Apply SHA-256 hash function
    return digest.toString(); // Return the hashed string
  }

  Future<void> _loadUserData() async {
    String? userkey = await getKey();

    userKey = userkey!;
  }
}
