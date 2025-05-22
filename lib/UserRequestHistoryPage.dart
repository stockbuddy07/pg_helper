import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'models/RegisterRetrieveModel.dart';

class RequestHistoryPage extends StatefulWidget {
  const RequestHistoryPage({super.key});

  @override
  State<RequestHistoryPage> createState() => _RequestHistoryPageState();
}

class _RequestHistoryPageState extends State<RequestHistoryPage> {
  final DatabaseReference tblUserRef =
  FirebaseDatabase.instance.ref('PG_helper/tblUser');

  List<RegisterRetrieveModel> historyUsers = [];

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  void fetchHistory() {
    tblUserRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      List<RegisterRetrieveModel> historyList = [];

      if (data != null) {
        data.forEach((key, value) {
          RegisterRetrieveModel user = RegisterRetrieveModel.fromJson(value, key);
          if (user.status == "Verified" || user.status == "allocated") {
            historyList.add(user);
          }
        });
      }

      setState(() {
        historyUsers = historyList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Request History"),
        backgroundColor: const Color(0xff12d3c6),
      ),
      body: historyUsers.isEmpty
          ? const Center(child: Text("No history records found."))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: historyUsers.length,
        itemBuilder: (context, index) {
          final user = historyUsers[index];
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
                          color: isDark ? Colors.teal[200] : Colors.teal[700])),
                  const SizedBox(height: 8),
                  _infoRow("Username", user.username ?? ''),
                  _infoRow("Email", user.email ?? ''),
                  _infoRow("Contact", user.contact ?? ''),
                  _infoRow("Bed Status", user.status ?? ''),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
