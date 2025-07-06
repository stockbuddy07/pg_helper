import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pg_helper/login.dart';
import 'package:pg_helper/privacy_policy.dart';
import 'package:pg_helper/profilePage.dart';
import 'package:pg_helper/queries.dart';
import 'package:pg_helper/saveSharePreferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ContactUs.dart';
import 'Services.dart';

class DrawerCode extends StatefulWidget {
  const DrawerCode({super.key});

  @override
  _DrawerCode createState() => _DrawerCode();
}

class _DrawerCode extends State<DrawerCode> {
  late String username = '';
  late String email = '';
  late String userFirstName = '';
  late String userLastName = '';
  String? profileImagePath;

  final key = 'username';
  final key1 = 'email';

  @override
  void initState() {
    super.initState();
    loadUser();
    _loadUserData();
  }

  Future<void> loadUser() async {
    String? userFirstname = await getData("firstname");
    String? userLastname = await getData("lastname");
    String? profileImage = await getData("userProfileImage"); // Load image path
    setState(() {
      userFirstName = userFirstname ?? '';
      userLastName = userLastname ?? '';
      profileImagePath = profileImage;
    });
  }

  Future<void> _loadUserData() async {
    String? userData = await getData(key);
    String? userEmail = await getData(key1);
    setState(() {
      username = userData ?? '';
      email = userEmail ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: const EdgeInsets.only(top: 20),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blueAccent,
                  backgroundImage: profileImagePath != null
                      ? (profileImagePath!.startsWith('http')
                      ? NetworkImage(profileImagePath!)
                      : FileImage(File(profileImagePath!)) as ImageProvider)
                      : null,
                  child: profileImagePath == null
                      ? Text(
                    username.isNotEmpty ? username[0].toUpperCase() : '',
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
                  )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(username,
                          style: const TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black)),
                      Text(email,
                          style: const TextStyle(
                              fontSize: 12.0, fontWeight: FontWeight.normal, color: Colors.black)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 5, color: Color(0xFFE0E3E7)),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined, color: Colors.black),
            title: const Text("My Account"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyProfile(username, email)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.room_service_outlined, color: Colors.black),
            title: const Text("Services"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Services()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.question_answer_outlined, color: Colors.black),
            title: const Text("My Queries"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const UserQnAView()));
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.email_outlined,
              color: Colors.black,
            ),
            title: const Text("Contact us"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ContactUs(
                        userFirstName: userFirstName,
                        userLastName: userLastName,
                      )));
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.privacy_tip_outlined,
              color: Colors.black,
            ),
            title: const Text("Privacy Policy"),
            onTap: () {
              // Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyWithConsent()));
            },
          ),
          const Divider(thickness: 5, color: Color(0xFFE0E3E7)),
          ListTile(
            leading: const Icon(Icons.logout_outlined, color: Colors.black),
            title: const Text("Log out"),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.clear();
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Login()));
            },
          ),
        ],
      ),
    );
  }
}
