// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously, avoid_print, camel_case_types

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pg_helper/UserChangePassword.dart';
import 'package:pg_helper/saveSharePreferences.dart';

class userPasswordChangeUserName extends StatefulWidget {
  const userPasswordChangeUserName({super.key});

  @override
  userPasswordChangeUserNameState createState() =>
      userPasswordChangeUserNameState();
}

class userPasswordChangeUserNameState
    extends State<userPasswordChangeUserName> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController controlleruname = TextEditingController();
  TextEditingController controllerpassword = TextEditingController();
  bool isPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(top: 16.0),
      child: Scaffold(
        key: _formKey,
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xff12d3c6), Color(0xff12d3c6)])),
              child: const Padding(
                padding: EdgeInsets.only(top: 60, left: 22),
                child: Text(
                  "Please, Enter Username",
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 200),
              child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40)),
                    color: Colors.white,
                  ),
                  height: double.maxFinite,
                  width: double.infinity,
                  child: Padding(
                    padding:
                    const EdgeInsets.only(top: 50, right: 20, left: 20),
                    child: Column(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                              const EdgeInsets.only(right: 20, left: 20),
                              child: Form(
                                key: _formKey,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: controlleruname,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter username';
                                          }
                                          return null;
                                        },
                                        decoration: const InputDecoration(
                                          prefixIcon: Icon(Icons.email_outlined,
                                              color: Color(0xff12d3c6)),
                                          prefixIconColor: Colors.blue,
                                          labelText: 'Username',
                                          filled: true,
                                          fillColor: Colors.white,
                                          hintText: 'Enter Username',
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        height: 50,
                                        width: 300,
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xff12d3c6),
                                              Color(0xff12d3c6)
                                            ],
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                        ),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              _performLogin(context);
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                          ),
                                          child: const Text(
                                            'Change Password',
                                            style:
                                            TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
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
    final scaffoldContext = context;

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
          count = count + 1;
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const UserChangePassword()));
        } else {
          msg = "Sorry..! No Username found";
          _showSnackbar(scaffoldContext, msg);
        }
      }
      if (count == 0) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Alert Message"),
              content: Text(msg.toString()),
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
}
