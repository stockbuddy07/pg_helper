// ignore_for_file: file_names, use_build_context_synchronously


import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:pg_helper/saveSharePreferences.dart';

import 'UserNewPassword.dart';

class UserChangePassword extends StatefulWidget {
  const UserChangePassword({super.key});

  @override
  State<UserChangePassword> createState() => _HospitalChangePasswordState();
}

class _HospitalChangePasswordState extends State<UserChangePassword> {
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerOTP = TextEditingController();
  EmailOTP myauth = EmailOTP();
  late String email;
  late String key;
  final key1 = 'email';
  final key2 = 'key';

  Future<void> _loadUserData() async {
    String? userEmail = await getData(key1);
    String? userKey = await getData(key2);
    setState(() {
      email = userEmail!;
      controllerEmail.text = email;
      key = userKey!;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Change your password',
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: GestureDetector(
              onTap: () async {
                myauth.setConfig(
                  appEmail: "arogyasair@gmail.com",
                  appName: "Arogya Sair",
                  userEmail: controllerEmail.text,
                  otpLength: 6,
                  otpType: OTPType.mixed,
                );
                myauth.setTheme(theme: "v2");
                if (await myauth.sendOTP() == true) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("OTP has been sent"),
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Oops, OTP send failed"),
                  ));
                }
              },
              child: AbsorbPointer(
                absorbing: true, // Disables text field interaction
                child: TextFormField(
                  controller: controllerEmail,
                  decoration: const InputDecoration(
                    hintText: "Email",
                    prefixIcon: Icon(Icons.mail),
                    suffixIcon: Icon(Icons.send), // Use any icon you need
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              controller: controllerOTP,
              decoration: const InputDecoration(
                hintText: "OTP",
                labelText: "Enter OTP",
                prefixIcon: Icon(Icons.password),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(10),
                  backgroundColor: const Color(0xff12d3c6)),
              onPressed: () async {
                if (await myauth.verifyOTP(otp: controllerOTP.text) == true) {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UserNewPassword()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Invalid OTP"),
                    ),
                  );
                }
              },
              child: const Text("Verify OTP",
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
