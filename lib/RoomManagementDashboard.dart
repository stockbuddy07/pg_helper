// RoomManagementDashboard.dart

import 'package:flutter/material.dart';
import 'package:pg_helper/AddRoomsPage.dart';
import 'ModifyRooms.dart';
import 'ShowRoomsPage.dart';

class RoomManagementDashboard extends StatefulWidget {
  const RoomManagementDashboard({super.key});

  @override
  State<RoomManagementDashboard> createState() => _RoomManagementDashboardState();
}

class _RoomManagementDashboardState extends State<RoomManagementDashboard> {

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
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
        title: const Text("Room Management"),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildCard(context, "Add Room", Icons.add_business, Colors.blueAccent, () {
              _navigate(context, AddRoomPage());
            }),
            _buildCard(context, "Show Rooms", Icons.meeting_room, Colors.blueAccent, () {
              _navigate(context, ShowRoomsPage());
            }),
            _buildCard(context, "Modify Rooms", Icons.edit, Colors.blueAccent, () {
              _navigate(context, const ModifyRoomsPage());
            }),
          ],
        ),
      ),
    );
  }
}
