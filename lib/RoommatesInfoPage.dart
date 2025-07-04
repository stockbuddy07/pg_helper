import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pg_helper/drawerSideNavigation.dart';
import 'package:pg_helper/saveSharePreferences.dart';
import 'package:url_launcher/url_launcher.dart';

class RoommatesInfoPage extends StatefulWidget {
  final String firstname;

  const RoommatesInfoPage({super.key, required this.firstname});

  @override
  State<RoommatesInfoPage> createState() => _RoommatesInfoPageState();
}

class _RoommatesInfoPageState extends State<RoommatesInfoPage> {
  List<Map<String, dynamic>> roommates = [];
  String? currentUserKey;
  String? currentRoomNumber;
  int currentSharing = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _listenToRoommates();
  }

  void _listenToRoommates() async {
    currentUserKey = await getKey();
    final usersRef = FirebaseDatabase.instance.ref('PG_helper/tblUser');

    usersRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null) return;

      final allUsers = Map<String, dynamic>.from(data as Map);
      final currentUserData = allUsers[currentUserKey];

      currentRoomNumber = currentUserData['RoomNumber'];
      currentSharing =
          int.tryParse(currentUserData['Sharing'].toString()) ?? 0;

      final others = allUsers.entries
          .where((entry) =>
      entry.key != currentUserKey &&
          entry.value['RoomNumber'] == currentRoomNumber)
          .map((e) => {
        "name":
        "${e.value['FirstName'] ?? ''} ${e.value['LastName'] ?? ''}",
        "contact": e.value['ContactNumber'] ?? '',
        "avatar": e.value['avatar'] ?? null,
      })
          .toList();

      while (others.length < currentSharing - 1) {
        others.add({"name": "", "contact": "", "avatar": null});
      }

      setState(() {
        roommates = others;
        isLoading = false;
      });
    });
  }

  Future<void> _callNumber(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendSMS(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget buildRoommateCard(Map<String, dynamic> rm) {
    final String name = rm['name'];
    final String contact = rm['contact'];
    final String firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: Colors.blueAccent.shade100,
              backgroundImage:
              rm['avatar'] != null ? NetworkImage(rm['avatar']) : null,
              child: rm['avatar'] == null && name.isEmpty
                  ? const Icon(Icons.person_outline,
                  color: Colors.white, size: 32)
                  : rm['avatar'] == null
                  ? Text(
                firstLetter,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              )
                  : null,
            ),
            const SizedBox(height: 10),
            Text(
              name.isNotEmpty ? name : "No roommate yet",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              contact.isNotEmpty ? contact : "Waiting for contact...",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            contact.isNotEmpty
                ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _callNumber(contact),
                  icon: const Icon(Icons.phone, color: Colors.white),
                  label: const Text("Call"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _sendSMS(contact),
                  icon: const Icon(Icons.message, color: Colors.white),
                  label: const Text("Message"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
              ],
            )
                : const Text(
              "Actions not available",
              style: TextStyle(color: Colors.redAccent),
            ),
          ],
        ),
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
            Text("Your Roommates",
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold)),
            Text(widget.firstname,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      endDrawer: const DrawerCode(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : roommates.isEmpty
          ? const Center(child: Text("No roommates found"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: roommates.length,
        itemBuilder: (context, index) {
          return buildRoommateCard(roommates[index]);
        },
      ),
    );
  }
}
