// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously, non_constant_identifier_names, prefer_typing_uninitialized_variables

// import 'package:arogyasair/EditProfile.dart';
// import 'package:arogyasair/LandingPage.dart';
// import 'package:arogyasair/UserChangePassword.dart';
// import 'package:arogyasair/about.dart';
// import 'package:arogyasair/contact.dart';
// import 'package:arogyasair/help_desk.dart';
// import 'package:arogyasair/saveSharePreferences.dart';
// import 'package:arogyasair/view_profile.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pg_helper/saveSharePreferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'EditProfile.dart';
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
  late Map data;
  late String username;
  late String name;
  late String mail;
  late String dateOfBirth;
  late String bloodGroup;
  var birthDate = "Select Birthdate";
  var selectedValue = 0;
  var selectedGender;
  late String userFirstName;
  late String userLastName;

  // late String username;
  late String userKey;
  late String fileName;
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
      userFirstName = userFirstname!;
      userLastName = userLastname!;
    });
  }

  Future<void> _loadUserData() async {
    String? userData = await getData(key);
    String? userEmail = await getData(key1);
    String? userkey = await getKey();

    username = userData!;
    email = userEmail!;
    userKey = userkey!;

    Ref = FirebaseDatabase.instance
        .ref()
        .child("PG_helper/tblUser")
        .orderByChild("Username")
        .equalTo(username);

    await Ref.once().then((documentSnapshot) async {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        actionsIconTheme: const IconThemeData(color: Color(0xff12d3c6)),
        actions: const [],
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Profile",
                textAlign: TextAlign.start,
                style:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
          ],
        ),
        iconTheme: const IconThemeData(
          color: Color(0xff12d3c6),
        ),
      ),
      endDrawer: const DrawerCode(),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
            child: InkWell(
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewProfile(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 5, 0, 0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.teal.shade500,
                      child: Text(
                        widget.username.isNotEmpty
                            ? widget.username[0].toUpperCase()
                            : '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Add some space between the avatar and the text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.username,
                            style: const TextStyle(
                                fontSize: 18, color: Colors.black),
                          ),
                          const Text('View Profile'),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ViewProfile(),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
            child: InkWell(
              onTap: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EditProfile()));
              },
              child: const Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(16, 20, 0, 20),
                      child: Text(
                        "Edit Profile",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserChangePassword()));
            },
            child: const Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(16, 20, 0, 20),
                    child: Text(
                      "Change Password",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () async {
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (context) => const AboutUs()));
            },
            child: const Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(16, 20, 0, 20),
                    child: Text(
                      "About Us",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () async {
              // Navigator.push(context,
              //     MaterialPageRoute(
              //         builder: (context) => ContactUs(
              //           userLastName: userLastName,
              //           userFirstName: userFirstName,
              //         )));
            },
            child: const Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(16, 20, 0, 20),
                    child: Text(
                      "Contact Us",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () async {
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (context) => const MyHelpDesk()));
            },
            child: const Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(16, 20, 0, 20),
                    child: Text(
                      "FAQ",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 2,
            thickness: 1,
            indent: 0,
            endIndent: 0,
            color: Colors.white12,
          ),
          InkWell(
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.clear();
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Login()));
            },
            child: const Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(16, 20, 0, 20),
                    child: Text(
                      "Log Out",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
                  child: Icon(
                    Icons.logout,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}