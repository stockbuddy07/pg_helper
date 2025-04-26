// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'models/RegisterModel.dart';
import 'models/RegisterRetrieveModel.dart';

class PendingUsersPage extends StatefulWidget {
  const PendingUsersPage({super.key});

  @override
  _PendingUsersPageState createState() => _PendingUsersPageState();
}

class _PendingUsersPageState extends State<PendingUsersPage> {
  DatabaseReference tblUserRef = FirebaseDatabase.instance.ref('PG_helper/tblUser');

  List<RegisterRetrieveModel> pendingUsers = [];

  @override
  void initState() {
    super.initState();
    fetchPendingUsers();
  }

  void fetchPendingUsers() {
    tblUserRef.onValue.listen((DatabaseEvent event) {
      List<RegisterRetrieveModel> usersList = [];
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        data.forEach((key, value) {
          RegisterRetrieveModel user = RegisterRetrieveModel.fromJson(value, key);
          if (user.status != "Verified") { // ✅ Filter here
            usersList.add(user);
          }
        });
      }
      setState(() {
        pendingUsers = usersList;
      });
    });
  }

  void confirmUser(RegisterRetrieveModel user) async {
    // Add to tblUser
    RegisterModel regObj = RegisterModel(
      user.username,
      user.password,
      user.email,
      user.name,
      user.Lastname,
      user.DOB,
      user.contact,
      "Verified", // ✅ Update status to Verified
    );
    await tblUserRef.push().set(regObj.toJson());

    // Remove from demoUser
    await tblUserRef.child(user.key!).remove();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User confirmed successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      body: pendingUsers.isEmpty
          ? const Center(child: Text('No pending users'))
          : ListView.builder(
        itemCount: pendingUsers.length,
        itemBuilder: (context, index) {
          final user = pendingUsers[index];
          return Card(
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            child: ListTile(
              title: Text('${user.name} ${user.Lastname}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Username: ${user.username}'),
                  Text('Email: ${user.email}'),
                  Text('Contact: ${user.contact}'),
                  Text('DOB: ${user.DOB}'),
                  Text('Status: ${user.status}'),
                ],
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff12d3c6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  confirmUser(user);
                },
                child: const Text('Confirm', style: TextStyle(color: Colors.white)),
              ),
            ),
          );
        },
      ),
    );
  }
}
