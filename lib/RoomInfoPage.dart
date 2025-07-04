import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pg_helper/models/RoomRetrievalModel.dart';
import 'saveSharePreferences.dart';

class RoomInfoPage extends StatefulWidget {
  final String firstname;

  const RoomInfoPage({super.key, required this.firstname});

  @override
  State<RoomInfoPage> createState() => _RoomInfoPageState();
}

class _RoomInfoPageState extends State<RoomInfoPage> {
  RoomRetrievalModel? roomInfo;
  String? roomNumber;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRoomData();
  }

  Future<void> fetchRoomData() async {
    String? userKey = await getKey();
    final userRef = FirebaseDatabase.instance.ref("PG_helper/tblUser/$userKey");
    final userSnapshot = await userRef.get();

    if (userSnapshot.exists) {
      roomNumber = userSnapshot.child("RoomNumber").value.toString();
      final roomsRef = FirebaseDatabase.instance.ref("PG_helper/tblRooms");

      final roomsSnapshot = await roomsRef.once();
      if (roomsSnapshot.snapshot.value != null) {
        final roomsMap = roomsSnapshot.snapshot.value as Map<dynamic, dynamic>;

        for (var entry in roomsMap.entries) {
          if (entry.value['RoomNumber'] == roomNumber) {
            setState(() {
              roomInfo = RoomRetrievalModel.fromMap(entry.key, entry.value);
              isLoading = false;
            });
            return;
          }
        }
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget buildInfoCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: const Offset(2, 3)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: Colors.blueAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f6f7),
      appBar: AppBar(
        backgroundColor: const Color(0xfff2f6f7),
        iconTheme: const IconThemeData(color: Colors.blueAccent),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Room Information", style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
            Text(widget.firstname, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : roomInfo == null
          ? const Center(child: Text("No room information found."))
          : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            buildInfoCard("Room Number", roomInfo!.roomNumber, Icons.confirmation_number),
            buildInfoCard("Room Size", roomInfo!.roomSize, Icons.straighten),
            buildInfoCard("Room Sharing", roomInfo!.roomSharing, Icons.people),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
