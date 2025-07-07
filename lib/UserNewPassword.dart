// ignore_for_file: file_names, use_build_context_synchronously
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pg_helper/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserNewPassword extends StatefulWidget {
  const UserNewPassword({super.key});

  @override
  State<UserNewPassword> createState() => _UserNewPasswordState();
}

class _UserNewPasswordState extends State<UserNewPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController controllerNewPassword = TextEditingController();
  TextEditingController controllerNewConfirmPassword = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('email');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: userEmail == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back Arrow
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        const Text(
                          "Reset Password",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Subtitle
                        const Text(
                          "Enter your new password below.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // New Password
                        TextFormField(
                          controller: controllerNewPassword,
                          obscureText: !isPasswordVisible,
                          validator: (value) =>
                          value!.isEmpty ? 'Please enter password' : null,
                          decoration: InputDecoration(
                            hintText: "New Password",
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: _togglePasswordVisibility,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Confirm Password
                        TextFormField(
                          controller: controllerNewConfirmPassword,
                          obscureText: !isConfirmPasswordVisible,
                          validator: (value) =>
                          value!.isEmpty ? 'Please re-enter password' : null,
                          decoration: InputDecoration(
                            hintText: "Confirm Password",
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: _toggleConfirmPasswordVisibility,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Illustration Image
                        Center(
                          child: SizedBox(
                            height: 240,
                            child: Image.asset(
                              'assets/pass_back.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final newPassword = controllerNewPassword.text;
                                final newConfirmPassword =
                                    controllerNewConfirmPassword.text;

                                if (newPassword == newConfirmPassword) {
                                  await updatePasswordUsingEmail();
                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.clear();

                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (_) => const Login()),
                                        (route) => false,
                                  );
                                } else {
                                  _showErrorDialog("Both passwords must be the same!");
                                }
                              }
                            },
                            child: const Text(
                              "Change Password",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Extra space for keyboard if open
                        MediaQuery.of(context).viewInsets.bottom > 0
                            ? SizedBox(height: MediaQuery.of(context).viewInsets.bottom)
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() => isPasswordVisible = !isPasswordVisible);
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() => isConfirmPasswordVisible = !isConfirmPasswordVisible);
  }

  String encryptString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> updatePasswordUsingEmail() async {
    final DatabaseReference usersRef =
    FirebaseDatabase.instance.ref().child("PG_helper/tblUser");

    final snapshot = await usersRef.get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> users = snapshot.value as Map<dynamic, dynamic>;
      for (var entry in users.entries) {
        Map<dynamic, dynamic> user = entry.value;
        if (user['Email'] == userEmail) {
          String encrypted = encryptString(controllerNewPassword.text);
          await usersRef.child(entry.key).update({'Password': encrypted});
          break;
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }
}
