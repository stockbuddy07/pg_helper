// RoomManagementDashboard.dart

import 'package:flutter/material.dart';
import 'package:pg_helper/AddRoomsPage.dart';
import 'ModifyRooms.dart';
import 'ShowRoomsPage.dart';

class RoomManagementDashboard extends StatelessWidget {
  const RoomManagementDashboard({super.key});

  void _navigate(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
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
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Room Management"),
        backgroundColor: Color(0xff12d3c6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildCard(context, "Add Room", Icons.add_business, Colors.deepPurple, () {
              _navigate(context, AddRoomPage());
            }),
            _buildCard(context, "Show Rooms", Icons.meeting_room, Colors.green, () {
              _navigate(context, ShowRoomsPage());
            }),
            _buildCard(context, "Modify Rooms", Icons.edit, Colors.orange, () {
              _navigate(context, const ModifyRoomsPage());
            }),
          ],
        ),
      ),
    );
  }
}
