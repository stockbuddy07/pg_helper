import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pg_helper/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'BottomNavigation.dart';
import 'firebase_options.dart';
import 'AdminHomePage.dart';
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

  Future<Widget> getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2)); // Splash delay

    final username = prefs.getString("username");
    final email = prefs.getString("email");
    final status = prefs.getString("status");

    if (username == null || email == null) {
      return const Login();
    }

    if (email == "shubham@admin.com") {
      return const AdminHomePage(0);
    } else if (status == "Verified") {
      return const BottomBar();
    } else {
      return const Login(); // fallback for unverified or wrong data
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: Image.asset(
                  'assets/staymate1.png',
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return const Scaffold(
              body: Center(child: Text("Error loading app")),
            );
          } else {
            return snapshot.data!;
          }
        },
      ),
    );
  }
}