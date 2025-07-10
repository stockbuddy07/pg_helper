import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pg_helper/AddMeals.dart';
import 'package:pg_helper/login.dart';
import 'package:pg_helper/pendingUserList.dart';
import 'package:pg_helper/AdminQuestionView.dart';
import 'package:pg_helper/students_list_admin_side.dart';
import 'package:pg_helper/RoomManagementDashboard.dart';
import 'package:pg_helper/ShowRoomsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class AdminHomePage extends StatefulWidget {
  final int indexPage;

  const AdminHomePage(this.indexPage, {super.key});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String displayName = " Admin";
  int totalStudents = 0;
  int pendingCount = 0;
  int _selectedIndex = 0;

  late final PageController _pageController;

  final DatabaseReference _usersRef =
  FirebaseDatabase.instance.ref().child('PG_helper/tblUser');
  final DatabaseReference _pendingRef =
  FirebaseDatabase.instance.ref().child('PG_helper/pendingRequests');

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _fetchCounts();
  }

  Future<void> _fetchCounts() async {
    final userSnap = await _usersRef.once();
    final pendingSnap = await _pendingRef.once();

    if (mounted) {
      setState(() {
        totalStudents = userSnap.snapshot.value != null
            ? (userSnap.snapshot.value as Map).length
            : 0;
        pendingCount = pendingSnap.snapshot.value != null
            ? (pendingSnap.snapshot.value as Map).length
            : 0;
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

  List<Widget> _navItems() {
    final icons = [
      Icons.dashboard,
      Icons.people,
      Icons.notifications,
      Icons.chat_bubble,
    ];

    return List.generate(icons.length, (index) {
      bool isActive = _selectedIndex == index;

      return AnimatedContainer(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOutCubicEmphasized,
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.white : Colors.transparent,
          boxShadow: isActive
              ? [
            BoxShadow(
              color: Colors.white.withOpacity(0.6),
              blurRadius: 8,
              spreadRadius: 1,
              offset: Offset(0, 2),
            )
          ]
              : [],
        ),
        child: Icon(
          icons[index],
          color: isActive ? Colors.deepPurple : Colors.white,
          size: 28,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text(
              "Welcome$displayName",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.deepPurple),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: [
          _buildDashboardPage(),
          StudentsListAdminSide(),
          PendingUsersPage(),
          AdminQuestionView(),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60,
        backgroundColor: Colors.transparent,
        color: Colors.deepPurple,
        buttonBackgroundColor: Colors.white,
        animationDuration: Duration(milliseconds: 300),
        onTap: (index) {
          setState(() => _selectedIndex = index);
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 700),
            curve: Curves.easeOutExpo, // smoother than easeInOutCubic
          );
        },
        items: _navItems(),
      ),
    );
  }

  Widget _buildDashboardPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoCard(
            title: "Total Students",
            value: "$totalStudents",
            icon: Icons.people,
            color: Colors.deepPurple,
          ),
          SizedBox(height: 30),
          Text("Admin Dashboard",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
            children: [
              _buildCard("Add Rooms", Icons.room_preferences_outlined,
                  Colors.indigoAccent, () => _navigate(RoomManagementDashboard())),
              _buildCard("Add Meals", Icons.fastfood_outlined, Colors.orange,
                      () => _navigate(AddDailyMeal())),
              _buildCard("User Requests", Icons.group_add, Colors.teal,
                      () => _navigate(PendingUsersPage())),
              _buildCard("Show Rooms", Icons.meeting_room, Colors.blueAccent,
                      () => _navigate(ShowRoomsPage())),
            ],
          ),
        ],
      ),
    );
  }

  void _navigate(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300, blurRadius: 8, offset: Offset(2, 4)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 16, color: Colors.black54)),
              SizedBox(height: 6),
              Text(value,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 8,
                offset: Offset(2, 4)),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 22, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 38, color: color),
            SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
