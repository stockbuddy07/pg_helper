import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pg_helper/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'BottomNavigation.dart';
import 'firebase_options.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2)); // Splash delay
    return prefs.containsKey("username");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: checkLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: Image.asset(
                  'assets/staymate1.png', // Path to your image
                  width: 250,        // Optional: adjust size
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),
            );
          }
          else if (snapshot.hasError) {
            return const Scaffold(
              body: Center(child: Text("Error loading app")),
            );
          } else {
            return snapshot.data! ? const BottomBar() : const Login();
          }
        },
      ),
    );
  }
}
