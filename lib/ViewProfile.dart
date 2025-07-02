// ignore_for_file: file_names, use_build_context_synchronously

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pg_helper/saveSharePreferences.dart';
import 'EditProfile.dart';

class ViewProfile extends StatefulWidget {
  const ViewProfile({super.key});

  @override
  _ViewProfileState createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  final key = 'username';
  final key1 = 'email';

  late String controllerUsername = '';
  late String controllerName = '';
  late String controllerEmail = '';
  late String controllerDOB = '';
  late String controllerBloodGroup = '';
  late String selectedGender = '';
  late String userKey;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await getData(key) ?? '';
    final userEmail = await getData(key1) ?? '';
    final keyData = await getKey() ?? '';

    controllerUsername = userData;
    controllerEmail = userEmail;
    userKey = keyData;

    final ref = FirebaseDatabase.instance
        .ref()
        .child("ArogyaSair/tblUser")
        .orderByChild("Username")
        .equalTo(controllerUsername);

    final snapshot = await ref.once();

    for (final x in snapshot.snapshot.children) {
      final data = x.value as Map;

      controllerUsername = (data["Username"] ?? "").toString();
      controllerName = (data["Name"] ?? "").toString();
      controllerEmail = (data["Email"] ?? "").toString();
      controllerDOB = (data["DOB"] ?? "").toString();
      controllerBloodGroup = (data["BloodGroup"] ?? "").toString();
      selectedGender = (data["Gender"] ?? "").toString();
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildInfoTile(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.arrow_right, color: Colors.blueAccent),
          title: Text(title),
          subtitle: Text(value.isNotEmpty ? value : "Not Provided"),
        ),
        const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("View Profile", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.blueAccent),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blueAccent),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfile()),
            ),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    controllerUsername.isNotEmpty
                        ? controllerUsername[0].toUpperCase()
                        : '',
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoTile("Name", controllerName),
              _buildInfoTile("Username", controllerUsername),
              _buildInfoTile("Email", controllerEmail),
              _buildInfoTile("Date of Birth", controllerDOB),
              _buildInfoTile("Blood Group", controllerBloodGroup),
              _buildInfoTile("Gender", selectedGender),
            ],
          ),
        ),
      ),
    );
  }
}
