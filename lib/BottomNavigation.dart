// ignore_for_file: file_names, camel_case_types, library_private_types_in_public_api

// import 'package:arogyasair/HistoryPage.dart';
// import 'package:arogyasair/HomePage.dart';
// import 'package:arogyasair/ProfilePage.dart';
// import 'package:arogyasair/UpdatesPage.dart';
// import 'package:arogyasair/saveSharePreferences.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:pg_helper/AddMeals.dart';
import 'package:pg_helper/HomePage.dart';
import 'package:pg_helper/profilePage.dart';
import 'package:pg_helper/saveSharePreferences.dart';

import 'HelpDesk.dart';
import 'PaymentHistory.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;
  late String username;
  late String email;
  final key = 'username';
  final key1 = 'email';
  late String firstName;
  late String userKey;
  List<Widget> _widgetOptions = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String? userData = await getData(key);
    String? userEmail = await getData(key1);
    String? userFirstName = await getData("firstname");
    String? userkey = await getKey();
    setState(() {
      username = userData!;
      email = userEmail!;
      userKey = userkey!;
      firstName = userFirstName!;
    });
    _widgetOptions = <Widget>[
      Scaffold(
        backgroundColor: Colors.white,
        body: HomePage(
          firstname: firstName,
        ),
      ),
      const Scaffold(
        backgroundColor: Colors.white,
        body: PaymentHistory(),
      ),
      const Scaffold(
        backgroundColor: Colors.white,
        body: HelpDesk(),
      ),
      Scaffold(
        backgroundColor: Colors.white,
        body: MyProfile(username, email),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: CurvedNavigationBar(
          backgroundColor: Colors.white,
          color: const Color(0xff12d3c6),
          animationDuration: const Duration(milliseconds: 500),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            _buildIcon(Icons.home, 0),
            _buildIcon(Icons.update, 1),
            _buildIcon(Icons.history, 2),
            _buildIcon(Icons.person, 3),
          ],
          index: _selectedIndex, // Use 'index' instead of 'currentIndex'
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }
}
