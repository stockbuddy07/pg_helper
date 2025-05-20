
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pg_helper/room_issue.dart';
import 'package:pg_helper/saveSharePreferences.dart';

import 'BottomNavigation.dart';
import 'drawerSideNavigation.dart';
import 'electricity_issue.dart';
import 'food_issue.dart';
import 'internet_issue.dart';
import 'models/userAskQuestion.dart';



class MyHelpDesk extends StatefulWidget {
  const MyHelpDesk({super.key});

  @override
  State<MyHelpDesk> createState() => _MyHelpDeskState();
}

class _MyHelpDeskState extends State<MyHelpDesk> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textFieldController = TextEditingController();
  late String userKey;
  DatabaseReference dbRef2 =
  FirebaseDatabase.instance.ref().child('ArogyaSair/tblUserQuestions');

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String? userData = await getKey();
    setState(() {
      userKey = userData!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfff2f6f7),
        automaticallyImplyLeading: false,
        title: const Text(
          'Help Desk',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xff12d3c6)),
      ),
      endDrawer: const DrawerCode(),
      body: Container(
        color: const Color(0xfff2f6f7),
        child: ListView(
          children: [
            // Lottie animation card
            Card(
              elevation: 8,
              margin: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xff12d3c6), Color(0xff12d3c6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 150,
                  child: Center(
                    child: Lottie.asset(
                      'assets/Animation/help_desk.json',
                      repeat: true,
                      reverse: true,
                    ),
                  ),
                ),
              ),
            ),
            // 2x2 Grid for Room, Electricity, Food, Internet
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1, // square
                children: [
                  _issueCardBox(context, 'Electricity', Icons.electrical_services),
                  _issueCardBox(context, 'Room', Icons.meeting_room),
                  _issueCardBox(context, 'Food', Icons.restaurant),
                  _issueCardBox(context, 'Internet', Icons.wifi),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Helper method to create square card
  Widget _issueCardBox(BuildContext context, String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        Widget page;
        switch (title) {
          case 'Electricity':
            page = const ElectricityIssuePage();
            break;
          case 'Room':
            page = const RoomIssuePage();
            break;
          case 'Food':
            page = const FoodIssuePage();
            break;
          case 'Internet':
            page = const InternetIssuePage();
            break;
          default:
            page = const ElectricityIssuePage(); // fallback
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              offset: const Offset(2, 2),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xff12d3c6)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

}
