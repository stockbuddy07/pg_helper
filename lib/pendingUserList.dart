import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'UserConfirmationPage.dart';
import 'models/RegisterRetrieveModel.dart';

class PendingUsersPage extends StatefulWidget {
  const PendingUsersPage({super.key});

  @override
  _PendingUsersPageState createState() => _PendingUsersPageState();
}

class _PendingUsersPageState extends State<PendingUsersPage> {
  final DatabaseReference tblUserRef =
  FirebaseDatabase.instance.ref('PG_helper/tblUser');

  List<RegisterRetrieveModel> pendingUsers = [];
  List<RegisterRetrieveModel> historyUsers = [];

  bool showHistory = false; // For dropdown

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  void fetchUsers() {
    tblUserRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      List<RegisterRetrieveModel> pendingList = [];
      List<RegisterRetrieveModel> historyList = [];

      if (data != null) {
        data.forEach((key, value) {
          final user = RegisterRetrieveModel.fromJson(value, key);
          if (user.status != "Verified" && user.status != "allocated") {
            pendingList.add(user);
          } else {
            historyList.add(user);
          }
        });
      }

      setState(() {
        pendingUsers = pendingList;
        historyUsers = historyList;
      });
    });
  }

  void navigateToConfirmationPage(RegisterRetrieveModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            UserConfirmationPage(user: user, tblUserRef: tblUserRef),
      ),
    );
  }

  void confirmRejectUser(String userId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reject User"),
        content: const Text("Are you sure you want to reject and delete this user request?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text("Reject", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop();
              rejectUser(userId);
            },
          ),
        ],
      ),
    );
  }

  void rejectUser(String userId) async {
    try {
      await tblUserRef.child(userId).remove();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User rejected and removed.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rejecting user: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pending User Requests"),
        backgroundColor: const Color(0xff12d3c6),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pending Requests", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            pendingUsers.isEmpty
                ? const Text('No Pending Users', style: TextStyle(fontSize: 16))
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pendingUsers.length,
              itemBuilder: (context, index) {
                final user = pendingUsers[index];
                return _buildUserCard(user, isDark, isPending: true);
              },
            ),
            const SizedBox(height: 24),

            /// --- DROPDOWN HISTORY ---
            GestureDetector(
              onTap: () => setState(() => showHistory = !showHistory),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Request History", style: Theme.of(context).textTheme.titleMedium),
                      Icon(showHistory ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ),
            ),
            if (showHistory)
              historyUsers.isEmpty
                  ? const Padding(
                padding: EdgeInsets.all(8),
                child: Text('No History Yet', style: TextStyle(fontSize: 16)),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: historyUsers.length,
                itemBuilder: (context, index) {
                  final user = historyUsers[index];
                  return _buildUserCard(user, isDark, isPending: false);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(RegisterRetrieveModel user, bool isDark, {required bool isPending}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${user.name ?? ''} ${user.Lastname ?? ''}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.teal[200] : Colors.teal[700],
                )),
            const SizedBox(height: 8),
            _infoRow("Username", user.username ?? ''),
            _infoRow("Email", user.email ?? ''),
            _infoRow("Contact", user.contact ?? ''),
            _infoRow("Bed Status", user.status ?? ''),
            if (isPending) const SizedBox(height: 12),
            if (isPending)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => navigateToConfirmationPage(user),
                      icon: const Icon(Icons.remove_red_eye),
                      label: const Text('Confirm'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1fd128),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => confirmRejectUser(user.key ?? ''),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}
