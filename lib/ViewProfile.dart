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
  late String controllerContact = '';
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
        .child("PG_helper/tblUser")
        .orderByChild("Username")
        .equalTo(controllerUsername);

    final snapshot = await ref.once();

    for (final x in snapshot.snapshot.children) {
      final data = x.value as Map;

      controllerUsername = (data["Username"] ?? "").toString();
      controllerName = (data["FirstName"]+data["LastName"] ?? "").toString();
      controllerEmail = (data["Email"] ?? "").toString();
      controllerContact = (data["Contact"] ?? "").toString();
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIconForTitle(title),
              color: Colors.blueAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : "Not Provided",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case "Name":
        return Icons.person_outline;
      case "Username":
        return Icons.alternate_email;
      case "Email":
        return Icons.email_outlined;
      case "Contact":
        return Icons.phone_iphone_outlined;
      case "Date of Birth":
        return Icons.calendar_today_outlined;
      case "Blood Group":
        return Icons.favorite_border_outlined;
      case "Gender":
        return Icons.transgender_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.blueAccent),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit,
                  color: Colors.blueAccent,
                  size: 20,
              ),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfile()),
            ),
          )
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
        ),
      )
          : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blueAccent.withOpacity(0.2),
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.blueAccent,
                            child: Text(
                              controllerUsername.isNotEmpty
                                  ? controllerUsername[0].toUpperCase()
                                  : '',
                              style: const TextStyle(
                                fontSize: 36,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildInfoTile("Name", controllerName),
              _buildInfoTile("Username", controllerUsername),
              _buildInfoTile("Email", controllerEmail),
              _buildInfoTile("Contact", controllerContact),
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