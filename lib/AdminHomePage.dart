// ignore_for_file: file_names, library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pg_helper/AddMeals.dart';
import 'package:pg_helper/login.dart';
import 'package:pg_helper/pendingUserList.dart';
import 'package:pg_helper/saveSharePreferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AdminQuestionView.dart';
import 'firebase_api.dart';

class AdminHomePage extends StatefulWidget {
  final int indexPage;

  const AdminHomePage(this.indexPage, {super.key});

  @override
  _HospitalHomePage createState() => _HospitalHomePage();
}

class _HospitalHomePage extends State<AdminHomePage> {
  Query dbRef2 =
  FirebaseDatabase.instance.ref().child('PG_helper/tblUser');
  late String Name;
  late String? userKey;
  final key = 'Name';
  late bool containsKey;
  var logger = Logger();
  late String displayName="demo";
  final _messagingService = MessagingService();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  late String? fcmToken;
  @override
  void initState() {
    super.initState();
    // _loadUserData();
  }



  @override
  Widget build(BuildContext context) {
    if (displayName.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return DefaultTabController(
        initialIndex: widget.indexPage,
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xff12d3c6),
            title: Text(
              displayName,
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              PopupMenuButton(
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem(
                      value: 'my_account',
                      child: Text('My Account'),
                    ),
                    const PopupMenuItem(
                      value: 'Privacy policy',
                      child: Text('Privacy Policy'),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Text('Logout'),
                    ),
                  ];
                },
                onSelected: (value) async {
                  // Handle menu item selection here
                  if (value == 'my_account') {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => HospitalProfile()));
                  } else if (value == 'Privacy policy') {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => PrivacyPolicy()));
                    // Handle Settings
                  } else if (value == 'logout') {
                    SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                    prefs.clear();
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Login(),
                      ),
                    );
                  }
                },
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
              ),
            ],
            bottom: TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white,
              tabs: const [
                Tab(
                  child: Text(
                    "ADD MEALS",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Tab(
                    child: Text(
                      "REQUESTS",
                      style: TextStyle(color: Colors.white),
                    )),
                Tab(
                    child: Text(
                      "APPOINTMENTS",
                      style: TextStyle(color: Colors.white),
                    )),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Center(
                child: AddDailyMeal(),
              ),
              Center(
                child: PendingUsersPage(),
              ),
              Center(
                child: AdminQuestionView(),
              ),
            ],
          ),
        ),
      );
    }
  }
}
