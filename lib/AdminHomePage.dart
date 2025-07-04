// ignore_for_file: file_names, library_private_types_in_public_api, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pg_helper/AddMeals.dart';
import 'package:pg_helper/login.dart';
import 'package:pg_helper/pendingUserList.dart';
import 'package:pg_helper/AdminQuestionView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pg_helper/RoomManagementDashboard.dart';

class AdminHomePage extends StatefulWidget {
  final int indexPage;

  const AdminHomePage(this.indexPage, {super.key});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String displayName = "Welcome Admin";
  int totalStudents = 0;

  final DatabaseReference _usersRef =
  FirebaseDatabase.instance.ref().child('PG_helper/tblUser');

  @override
  void initState() {
    super.initState();
    _fetchTotalStudents();
  }

  Future<void> _fetchTotalStudents() async {
    final snapshot = await _usersRef.once();
    if (snapshot.snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
      setState(() {
        totalStudents = data.length;
      });
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  void _navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(displayName, style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoCard(
              title: "Total Users",
              value: "$totalStudents",
              color: Colors.blueAccent,
              icon: Icons.people,
            ),

            SizedBox(height: 24),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDashboardCard("Add Rooms", Icons.meeting_room, Colors.blueAccent, () {
                  _navigateToPage(RoomManagementDashboard());
                }),
                _buildDashboardCard("Add Meals", Icons.fastfood, Colors.blueAccent, () {
                  _navigateToPage(AddDailyMeal());
                }),
                _buildDashboardCard("User Requests", Icons.group, Colors.blueAccent, () {
                  _navigateToPage(PendingUsersPage());
                }),
                _buildDashboardCard("Appointments", Icons.event, Colors.blueAccent, () {
                  _navigateToPage(AdminQuestionView());
                }),
              ],
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({required String title, required String value, required Color color, required IconData icon}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: Offset(2, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
              SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: Offset(2, 2)),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
