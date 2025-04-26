import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class UserApprovalPage extends StatefulWidget {
  const UserApprovalPage({super.key});

  @override
  _UserApprovalPageState createState() => _UserApprovalPageState();
}

class _UserApprovalPageState extends State<UserApprovalPage> {
  DatabaseReference userCnfRef = FirebaseDatabase.instance.ref().child('PG_helper/usercnf');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending User Approvals')),
      body: StreamBuilder(
        stream: userCnfRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> users = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            List<MapEntry<dynamic, dynamic>> userEntries = users.entries.toList();

            return ListView.builder(
              itemCount: userEntries.length,
              itemBuilder: (context, index) {
                var user = userEntries[index].value;
                var userKey = userEntries[index].key;

                return Card(
                  child: ListTile(
                    title: Text("${user['FirstName']} ${user['LastName']}"),
                    subtitle: Text("Username: ${user['Username']} \nEmail: ${user['Email']}"),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _approveUser(userKey, user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _rejectUser(userKey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No pending users.'));
          }
        },
      ),
    );
  }

  void _approveUser(String userKey, Map userData) async {
    DatabaseReference tblUserRef = FirebaseDatabase.instance.ref().child('PG_helper/tblUser');

    await tblUserRef.push().set(userData); // Move to tblUser
    await userCnfRef.child(userKey).remove(); // Remove from usercnf

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User approved successfully!')),
    );
  }

  void _rejectUser(String userKey) async {
    await userCnfRef.child(userKey).remove(); // Just delete

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User rejected!')),
    );
  }
}
