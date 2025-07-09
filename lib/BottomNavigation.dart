// ignore_for_file: file_names, camel_case_types, library_private_types_in_public_api

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:pg_helper/HomePage.dart';
import 'package:pg_helper/saveSharePreferences.dart';

import 'HelpDesk.dart';
import 'PaymentHistory.dart';
import 'bottom_profilePage.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;
  String? username;
  String? email;
  String? firstName;
  String? userKey;
  List<Widget> _widgetOptions = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String? userData = await getData('username');
    String? userEmail = await getData('email');
    String? userFirstName = await getData("firstname");
    String? userkey = await getKey();

    if (userData != null && userEmail != null && userFirstName != null && userkey != null) {
      setState(() {
        username = userData;
        email = userEmail;
        firstName = userFirstName;
        userKey = userkey;

        _widgetOptions = <Widget>[
          Scaffold(
            backgroundColor: Colors.white,
            body: HomePage(
              firstname: firstName!,
            ),
          ),
          const Scaffold(
            backgroundColor: Colors.white,
            body: UpiPaymentPage(),
          ),
          const Scaffold(
            backgroundColor: Colors.white,
            body: MyHelpDesk(),
          ),
          Scaffold(
            backgroundColor: Colors.white,
            body: MyProfile1(username!, email!),
          ),
        ];
      });
    } else {
      // Handle missing data if necessary
      setState(() {
        _widgetOptions = [
          const Center(child: Text("Failed to load user data")),
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _widgetOptions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: _widgetOptions.length < 4
          ? null // Hide nav bar until all tabs are ready
          : Container(
        color: Colors.white,
        child: CurvedNavigationBar(
          backgroundColor: const Color(0x0000ffff),
          color: Colors.blueAccent,
          animationDuration: const Duration(milliseconds: 500),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            _buildIcon(Icons.home, 0),
            _buildIcon(Icons.update, 1),
            _buildIcon(Icons.live_help_outlined, 2),
            _buildIcon(Icons.person, 3),
          ],
          index: _selectedIndex,
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
