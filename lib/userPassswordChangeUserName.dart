// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously, avoid_print, camel_case_types

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pg_helper/UserChangePassword.dart';
import 'package:pg_helper/saveSharePreferences.dart';

class userPasswordChangeUserName extends StatefulWidget {
  const userPasswordChangeUserName({super.key});

  @override
  userPasswordChangeUserNameState createState() => userPasswordChangeUserNameState();
}

class userPasswordChangeUserNameState extends State<userPasswordChangeUserName> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController controlleruname = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back arrow
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 16),

                // Title
                const Text(
                  "Forgot password",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  "Enter your username to reset your password",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),

                const SizedBox(height: 24),

                // Username field
                TextFormField(
                  controller: controlleruname,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter username';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Username",
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Image inserted between TextField and Button
                Center(
                  child: SizedBox(
                    height: 280,
                    child: Image.asset(
                      'assets/pass_back.png', // Replace with your image path
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const Spacer(),

                // Change Password Button
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
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Change Password',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
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
    var username = controlleruname.text;
    Query dbRef2 = FirebaseDatabase.instance
        .ref()
        .child('PG_helper/tblUser')
        .orderByChild("Username")
        .equalTo(username);
    String msg = "No Username found";
    Map data;
    var count = 0;

    await dbRef2.once().then((documentSnapshot) async {
      for (var x in documentSnapshot.snapshot.children) {
        String? key = x.key;
        data = x.value as Map;
        if (data["Username"] == username) {
          await saveData('email', data["Email"]);
          await saveData('key', key);
          count += 1;
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const UserChangePassword()));
        } else {
          msg = "Sorry..! No Username found";
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
              actions: [
                OutlinedButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            );
          },
        );
      }
    });
  }
}
