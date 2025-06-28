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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              // Email Field (disabled)
              GestureDetector(
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("OTP has been sent")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Oops, OTP send failed")),
                    );
                  }
                },
                child: AbsorbPointer(
                  absorbing: true,
                  child: TextFormField(
                    controller: controllerEmail,
                    decoration: InputDecoration(
                      hintText: "Email",
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      prefixIcon: const Icon(Icons.mail_outline),
                      suffixIcon: const Icon(Icons.send),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // OTP Field
              TextFormField(
                controller: controllerOTP,
                decoration: InputDecoration(
                  hintText: "OTP",
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  prefixIcon: const Icon(Icons.password),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Image (centered)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/otp_back.png', // 🖼️ Place your image here
                  height: 350,
                  fit: BoxFit.contain,
                ),
              ),

              const Spacer(),

              // Verify OTP Button
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
                    if (await myauth.verifyOTP(otp: controllerOTP.text) == true) {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserNewPassword(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Invalid OTP")),
                      );
                    }
                  },
                  child: const Text(
                    "Verify OTP",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
