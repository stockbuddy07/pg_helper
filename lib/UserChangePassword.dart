//verify otp screen(forgot password)
import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:pg_helper/saveSharePreferences.dart';
import 'UserNewPassword.dart';

class UserChangePassword extends StatefulWidget {
  const UserChangePassword({super.key});

  @override
  State<UserChangePassword> createState() => _UserChangePasswordState();
}

class _UserChangePasswordState extends State<UserChangePassword> {
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

  Future<void> sendOtp() async {
    showLoadingDialog(); // Show loading dialog

    myauth.setConfig(
      appEmail: "arogyasair@gmail.com",
      appName: "Arogya Sair",
      userEmail: controllerEmail.text,
      otpLength: 6,
      otpType: OTPType.mixed,
    );
    myauth.setTheme(theme: "v2");

    bool success = await myauth.sendOTP();

    Navigator.pop(context); // Close loading

    if (success) {
      showCustomAlert(
        title: "OTP Sent!",
        content: "An OTP has been sent to your email.",
        isSuccess: true,
      );
    } else {
      showCustomAlert(
        title: "Failed",
        content: "Oops, OTP sending failed. Try again.",
        isSuccess: false,
      );
    }
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(

        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),

      ),
    );
  }

  void showCustomAlert({required String title, required String content, required bool isSuccess}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back arrow
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        "Verify OTP",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "We have sent an OTP to your email",
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 24),

                      GestureDetector(
                        onTap: sendOtp,
                        child: AbsorbPointer(
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

                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/otp_back.png',
                            height: 280,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      const Spacer(),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (await myauth.verifyOTP(otp: controllerOTP.text)) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const UserNewPassword()),
                              );
                            } else {
                              showCustomAlert(
                                title: "Invalid OTP",
                                content: "Please check the OTP and try again.",
                                isSuccess: false,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Verify OTP",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      MediaQuery.of(context).viewInsets.bottom > 0
                          ? SizedBox(height: MediaQuery.of(context).viewInsets.bottom)
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
