// ignore_for_file: file_names, library_private_types_in_public_api, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pg_helper/AddMeals.dart';
import 'package:pg_helper/login.dart';
import 'package:pg_helper/pendingUserList.dart';
import 'package:pg_helper/AdminQuestionView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pg_helper/AddRoomsPage.dart';
import 'package:pg_helper/RoomManagementDashboard.dart';
import 'package:pg_helper/ShowRoomsPage.dart';

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
        title: Text(displayName),
        backgroundColor: Color(0xff12d3c6),
        automaticallyImplyLeading: false, // Hides back button
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Dashboard", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),

            // Total Students Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: Offset(2, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Users", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                  SizedBox(height: 8),
                  Text("$totalStudents", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal)),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Service Cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildDashboardCard("Add Rooms", Icons.meeting_room, Colors.deepPurple, () {
                  _navigateToPage(RoomManagementDashboard());
                }),
                _buildDashboardCard("Add Meals", Icons.fastfood, Colors.green, () {
                  _navigateToPage(AddDailyMeal());
                }),
                _buildDashboardCard("User Requests", Icons.group, Colors.blue, () {
                  _navigateToPage(PendingUsersPage());
                }),
                _buildDashboardCard("Appointments", Icons.event, Colors.orange, () {
                  _navigateToPage(AdminQuestionView());
                }),
              ],
            ),

            SizedBox(height: 20),

            // Logout Card
            GestureDetector(
              onTap: _logout,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: Offset(2, 2)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.white),
                    SizedBox(width: 10),
                    Text("Logout", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
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
