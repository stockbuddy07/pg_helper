// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously, non_constant_identifier_names, prefer_typing_uninitialized_variables

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
import 'login.dart';

class MyProfile extends StatefulWidget {
  final String username;
  final String email;

  const MyProfile(this.username, this.email, {super.key});

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  var imagePath =
      "https://firebasestorage.googleapis.com/v0/b/arogyasair-157e8.appspot.com/o/UserImage%2FDefaultProfileImage.png?alt=media";
  late Query Ref;
  Map data = {};
  late String username;
  late String name;
  late String mail;
  late String dateOfBirth;
  late String bloodGroup;
  String birthDate = "Select Birthdate";
  var selectedValue = 0;
  var selectedGender;
  String userFirstName = "";
  String userLastName = "";
  late String userKey;
  String imageName = "";
  late String email;
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

    setState(() {
      userFirstName = userFirstname ?? "";
      userLastName = userLastname ?? "";
    });
  }

  Future<void> _loadUserData() async {
    String? userData = await getData(key);
    String? userEmail = await getData(key1);
    String? userkey = await getKey();

    if (userData == null || userEmail == null || userkey == null) return;

    username = userData;
    email = userEmail;
    userKey = userkey;

    Ref = FirebaseDatabase.instance
        .ref()
        .child("PG_helper/tblUser")
        .orderByChild("Username")
        .equalTo(username);

    await Ref.once().then((documentSnapshot) {
      for (var x in documentSnapshot.snapshot.children) {
        data = x.value as Map;
        username = data["Username"];
        name = data["Name"];
        mail = data["Email"];
        dateOfBirth = data["DOB"];
        bloodGroup = data["BloodGroup"];
        selectedGender ??= data["Gender"];
        if (data["Photo"] != null) {
          imagePath =
          "https://firebasestorage.googleapis.com/v0/b/arogyasair-157e8.appspot.com/o/UserImage%2F${data["Photo"]}?alt=media";
          imageName = data["Photo"];
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        title: const Text(
          "My Profile",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w600, fontSize: 20),
        ),
        iconTheme: const IconThemeData(color: Colors.teal),
      ),
      endDrawer: const DrawerCode(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Profile Summary
            InkWell(
              onTap: () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ViewProfile()),
                  ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.teal.shade400,
                    child: Text(
                      widget.username.isNotEmpty
                          ? widget.username[0].toUpperCase()
                          : '',
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$userFirstName $userLastName',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const Text("View Profile",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),

            // Options
            buildFlatTile("✏️ Edit Profile", const EditProfile()),
            buildFlatTile("🔒 Change Password", const UserChangePassword()),
            buildFlatTile("ℹ️ About Us", const AboutUs()),
            buildFlatTile("📞 Contact Us", const ContactUs()),
            buildFlatTile("❓ FAQ", const MyHelpDesk()),

            // Logout
            InkWell(
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                      (route) => false,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("🚪 Log Out",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.red)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.logout, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 6), // Bottom space
          ],
        ),
      ),
    );
  }

  Widget buildFlatTile(String title, Widget? page) {
    return InkWell(
      onTap: page != null
          ? () =>
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => page))
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500)),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}