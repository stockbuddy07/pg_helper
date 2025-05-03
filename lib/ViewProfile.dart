// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously, non_constant_identifier_names, prefer_typing_uninitialized_variables

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pg_helper/saveSharePreferences.dart';

import 'EditProfile.dart';

class ViewProfile extends StatefulWidget {
  const ViewProfile({super.key});

  @override
  _ViewProfileState createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  var imagePath =
      "https://firebasestorage.googleapis.com/v0/b/arogyasair-157e8.appspot.com/o/UserImage%2FDefaultProfileImage.png?alt=media";
  late Query Ref;
  late Map data;
  late String controllerUsername;
  late String controllerFirstName;
  late String controllerLastName;
  late String controllerMail;
  late String controllerDateOfBirth;
  late String controllerBloodGroup;
  var birthDate = "Select Birthdate";
  var selectedValue = 0;
  var selectedGender;
  late String username;
  late String userKey;
  late String fileName;
  String imageName = "";
  late String email;
  late String userFirstName;
  late String userLastName;
  final key = 'username';
  final key1 = 'email';
  final key2 = 'userFirstName';
  final key3 = 'userLastName';

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
        controllerUsername = data["Username"];
        controllerFirstName = data["FirstName"];
        controllerLastName = data["LastName"];
        controllerMail = data["Email"];
        controllerDateOfBirth = data["DOB"];
        controllerBloodGroup = data["BloodGroup"];
        selectedGender ??= data["Gender"];
        if (data["Photo"] != null) {
          imagePath =
          "https://firebasestorage.googleapis.com/v0/b/arogyasair-157e8.appspot.com/o/UserImage%2F${data["Photo"]}?alt=media";
          imageName = data["Photo"];
        // }
      }
    }});
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xff12d3c6),
              title: const Text(
                'View Profile',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              actions: <Widget>[
                IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfile(),
                        ),
                      );
                    },
                    icon: const FaIcon(FontAwesomeIcons.userPen))
              ],
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xff12d3c6),
                      Color(0xff12d3c6),
                      Color(0xff12d3c6),
                    ],
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(130),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imagePath,
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: MediaQuery.of(context).size.height * 0.06,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controllerUsername,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        controllerMail,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Profile Information',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const Divider(height: 30, color: Colors.grey),
                            ListTile(
                              leading: const Icon(
                                Icons.person,
                                color: Color(0xff12d3c6),
                              ),
                              title: const Text(
                                'First Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(controllerFirstName),
                            ),
                            const Divider(height: 20, color: Colors.grey),
                            ListTile(
                              leading: const Icon(
                                Icons.person,
                                color: Color(0xff12d3c6),
                              ),
                              title: const Text(
                                'Last Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(controllerLastName),
                            ),
                            const Divider(height: 20, color: Colors.grey),
                            ListTile(
                              leading: const Icon(
                                Icons.wc,
                                color: Color(0xff12d3c6),
                              ),
                              title: const Text(
                                'Gender',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(selectedGender),
                            ),
                            const Divider(height: 20, color: Colors.grey),
                            ListTile(
                              leading: const Icon(
                                Icons.favorite,
                                color: Color(0xff12d3c6),
                              ),
                              title: const Text(
                                'Blood Group',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(controllerBloodGroup),
                            ),
                            const Divider(height: 20, color: Colors.grey),
                            ListTile(
                              leading: const Icon(
                                Icons.cake,
                                color: Color(0xff12d3c6),
                              ),
                              title: const Text(
                                'Date of Birth',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(controllerDateOfBirth),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
      future: _loadUserData(),
    );
  }
}
