import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'models/RegisterModel.dart';
import 'models/RegisterRetrieveModel.dart';
import 'package:pg_helper/showroom.dart';

class UserConfirmationPage extends StatelessWidget {
  final RegisterRetrieveModel user;
  final DatabaseReference tblUserRef;

  const UserConfirmationPage({
    super.key,
    required this.user,
    required this.tblUserRef,
  });

  Future<void> _confirmUser(BuildContext context) async {
    RegisterModel regObj = RegisterModel(
      user.username,
      user.password,
      user.email,
      user.name,
      user.Lastname,
      user.DOB,
      user.contact,
      "Verified",
    );

    await tblUserRef.push().set(regObj.toJson());
    await tblUserRef.child(user.key!).remove();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User confirmed successfully!')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => showroom(
          username: user.username,
          email: user.email,
          contact: user.contact,
        ),
      ),
    );
  }

  Future<void> _rejectUser(BuildContext context) async {
    await tblUserRef.child(user.key!).remove();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User rejected and data deleted successfully.')),
    );

    Navigator.pop(context);
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm User"),
        backgroundColor: const Color(0xff12d3c6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow("Name", "${user.name} ${user.Lastname}"),
            _infoRow("Username", user.username),
            _infoRow("Email", user.email),
            _infoRow("Contact", user.contact),
            _infoRow("DOB", user.DOB),
            _infoRow("Status", user.status),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.red[400],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: () => _rejectUser(context),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text("Reject", style: TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    color: const Color(0xff12d3c6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: () => _confirmUser(context),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text("Confirm", style: TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
