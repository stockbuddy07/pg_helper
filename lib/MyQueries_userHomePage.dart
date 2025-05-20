import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pg_helper/saveSharePreferences.dart';

class MyQueriesPage extends StatefulWidget {
  const MyQueriesPage({super.key});

  @override
  State<MyQueriesPage> createState() => _MyQueriesPageState();
}

class _MyQueriesPageState extends State<MyQueriesPage> {
  List<Map<String, dynamic>> myQueries = [];
  String? username;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserQueries();
  }

  Future<void> _fetchUserQueries() async {
    username = await getData("username");
    print("Logged-in username: $username");

    final dbRef = FirebaseDatabase.instance.ref("PG_helper/tblHelpDesk");

    dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      List<Map<String, dynamic>> queries = [];

      if (data != null) {
        data.forEach((key, value) {
          final queryUser = (value['username'] ?? "").toString().trim().toLowerCase();
          final currentUser = username?.trim().toLowerCase();

          print("Checking query from user: $queryUser");

          if (queryUser == currentUser) {
            queries.add({
              "query": value['query'] ?? "No query text",
              "response": value['response'] ?? "Pending...",
              "key": key,
            });
          }
        });
      }

      setState(() {
        myQueries = queries;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Queries"),
        backgroundColor: const Color(0xff12d3c6),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : myQueries.isEmpty
          ? const Center(child: Text("No queries raised yet."))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: myQueries.length,
        itemBuilder: (context, index) {
          final item = myQueries[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("📨 Query:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(item["query"], style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  const Text("✅ Admin Response:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(item["response"], style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
