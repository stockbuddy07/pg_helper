// ignore_for_file: file_names, use_build_context_synchronously, prefer_typing_uninitialized_variables

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pg_helper/saveSharePreferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AboutUs.dart';
import 'ContactUs.dart';
import 'EditProfile.dart';
import 'HelpDesk.dart';
import 'UserChangePassword.dart';
import 'ViewProfile.dart';
import 'drawerSideNavigation.dart';
import 'helpDesk_FAQ.dart';
import 'main.dart';

class MyProfile extends StatefulWidget {
  final String username;
  final String email;

  const MyProfile(this.username, this.email, {super.key});

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  String imagePath =
      "https://firebasestorage.googleapis.com/v0/b/arogyasair-157e8.appspot.com/o/UserImage%2FDefaultProfileImage.png?alt=media";

  Map data = {};
  String username = '';
  String name = '';
  String mail = '';
  String dateOfBirth = '';
  String bloodGroup = '';
  String selectedGender = '';
  String userFirstName = '';
  String userLastName = '';
  String userKey = '';
  String imageName = '';
  String email = '';

  final key = 'username';
  final key1 = 'email';

  @override
  void initState() {
    super.initState();
    loadUser();
    _loadUserData();
  }

  Future<void> loadUser() async {
    final userFirstname = await getData("firstname");
    final userLastname = await getData("lastname");

    setState(() {
      userFirstName = userFirstname ?? '';
      userLastName = userLastname ?? '';
    });
  }

  Future<void> _loadUserData() async {
    final userData = await getData(key) ?? '';
    final userEmail = await getData(key1) ?? '';
    final userkey = await getKey() ?? '';

    setState(() {
      username = userData;
      email = userEmail;
      userKey = userkey;
    });

    final ref = FirebaseDatabase.instance
        .ref()
        .child("PG_helper/tblUser")
        .orderByChild("Username")
        .equalTo(username);

    final snap = await ref.once();

    if (snap.snapshot.exists) {
      for (final x in snap.snapshot.children) {
        final mapData = x.value as Map<dynamic, dynamic>;

        setState(() {
          name = mapData["Name"] ?? '';
          mail = mapData["Email"] ?? '';
          dateOfBirth = mapData["DOB"] ?? '';
          bloodGroup = mapData["BloodGroup"] ?? '';
          selectedGender = mapData["Gender"] ?? '';
          imageName = mapData["Photo"] ?? '';

          if (imageName.isNotEmpty) {
            imagePath =
            "https://firebasestorage.googleapis.com/v0/b/arogyasair-157e8.appspot.com/o/UserImage%2F$imageName?alt=media";
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actionsIconTheme: const IconThemeData(color: Colors.blueAccent),
        backgroundColor: Colors.white,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      endDrawer: const DrawerCode(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ViewProfile()),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 5),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        username.isNotEmpty ? username[0].toUpperCase() : '',
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(username,
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.black)),
                          const Text('View Profile'),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios,
                          size: 18, color: Colors.black),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ViewProfile()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _menuTile('Edit Profile', const EditProfile()),
          _menuTile('Change Password', const UserChangePassword()),
          _menuTile('About Us', const AboutUs()),
          InkWell(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ContactUs(
                      userLastName: userLastName,
                      userFirstName: userFirstName,
                    ))),
            child: _menuRow('Contact Us'),
          ),
          _menuTile('FAQ', const MyHelpDesk_FAQ()),
          const Divider(thickness: 1, color: Colors.white12),
          InkWell(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MyApp()),
              );
            },
            child: _menuRow('Log Out', icon: Icons.logout),
          ),
        ],
      ),
    );
  }

  Widget _menuTile(String title, Widget page) => InkWell(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    ),
    child: _menuRow(title),
  );

  Widget _menuRow(String title, {IconData icon = Icons.arrow_forward_ios}) =>
      Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 0, 20),
              child: Text(title, style: const TextStyle(fontSize: 18)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(icon, size: 18, color: Colors.black),
          ),
        ],
      );
}
