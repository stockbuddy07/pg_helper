// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pg_helper/login.dart';
import 'package:pg_helper/profilePage.dart';
import 'package:pg_helper/queries.dart';
import 'package:pg_helper/saveSharePreferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Services.dart';

class DrawerCode extends StatefulWidget {
  const DrawerCode({super.key});

  @override
  _DrawerCode createState() => _DrawerCode();
}

class _DrawerCode extends State<DrawerCode> {
  late String username;
  late String email;
  final key = 'username';
  final key1 = 'email';
  late String userFirstName;
  late String userLastName;

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
    setState(() {
      username = userData!;
      email = userEmail!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: const EdgeInsets.only(top: 20),
        children: [
          Row(
            children: <Widget>[
              Flexible(
                child: Container(
                  width: 70,
                  height: 70,
                  padding: const EdgeInsets.only(bottom: 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    // Set your desired border radius
                    child: Image.asset(
                      'assets/Logo/ArogyaSair.png',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff12d3c6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(
            thickness: 5,
            color: Color(0xFFE0E3E7),
          ),
          ListTile(
            leading: const Icon(
              Icons.account_circle_outlined,
              color: Colors.black,
            ),
            title: const Text("My Account"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyProfile(username, email)));
            },
          ),
          ListTile(
            leading: const FaIcon(
              FontAwesomeIcons.suitcaseMedical,
              color: Colors.black,
            ),
            title: const Text("Services"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Services()));
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.info,
              color: Colors.black,
            ),
            title: const Text("About us"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const UserQnAView()));
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.email,
              color: Colors.black,
            ),
            title: const Text("Contact us"),
            onTap: () {
              // Navigator.pop(context);
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => ContactUs(
              //           userFirstName: userFirstName,
              //           userLastName: userLastName,
              //         )));
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.privacy_tip,
              color: Colors.black,
            ),
            title: const Text("Privacy Policy"),
            onTap: () {
              // // Navigator.pop(context);
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => const UserPrivacyPolicy()));
            },
          ),
          const Divider(
            thickness: 5,
            color: Color(0xFFE0E3E7),
          ),
          ListTile(
            leading: const Icon(
              Icons.logout_outlined,
              color: Colors.black,
            ),
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
